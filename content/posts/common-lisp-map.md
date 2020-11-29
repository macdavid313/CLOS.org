+++
title = "Common Lisp 中的 'map'"
date = 2016-11-01
tags = ["lisp"]
+++

> In many programming languages, map is the name of a higher-order function that applies a given function to each element of a list, returning a list of results in the same order. It is often called apply-to-all when considered in functional form. The concept of a map is not limited to lists: it works for sequential containers, tree-like containers, or even abstract containers such as futures and promises. —— Wikipedia[^1]

# Scheme 中的 map

`map` 在 Lisp 语言中是一个经典的操作符。在包括《计算机程序的构造与解释》的诸多教材里，`map` 都作为一个使用**高阶函数**的经典范例。我们首先考察，在“短小精悍”的 Scheme 语言中，`map` 的“签名”与使用方法如下：

```scheme
;;; procedure: (map procedure list1 list2 ...)
;;; returns: list of results
(map abs '(1 -2 3 -4 5 -6)) ;; => (1 2 3 4 5 6)
(map + '(1 2 3) '(3 2 1)) ;; => (4 4 4)
```

`map` 的作用在此很明了：对于列表中的每个元素应用一遍绝对值函数`abs`，然后返回一个由结果组成的列表。那么这个返回的列表和作为参数的列表之间有没有关系呢？

```scheme
(define lst-1 (list 1 -2 3 -4 5 -6))
(define lst-2 (map abs lst-1))
lst-2 ;; => (1 2 3 4 5 6)
(eq? lst-1 lst-2) ;; => #f
(set-car! lst-1 -1000)
lst-1 ;; => (-1000 -2 3 -4 5 -6)
lst-2 ;; => (1 2 3 4 5 6)
```

可以看到，`map` 并不会带来所谓的“副作用”；也就是说，`map` 不会肆意造成任何 `mutation`。`map` 所映射出来的列表完全是一个新的列表。事实上，`map` 完全可以由下面几行代码所实现[^2]：

```lisp
;;; am example implementation of `map` in Scheme
(define map
  (lambda (f ls . more)
    (if (null? more)
        (let map1 ([ls ls])
          (if (null? ls)
              '()
              (cons (f (car ls))
                    (map1 (cdr ls)))))
        (let map-more ([ls ls] [more more])
          (if (null? ls)
              '()
              (cons
               (apply f (car ls) (map car more))
               (map-more (cdr ls) (map cdr more))))))))
```

也许有人会说，`map` 这种没有“副作用”的机制是否也会随之带来较大的开销。这种担忧的确是值得考量的。**在我的理解中，函数式编程的代价即在于此：在效率上的牺牲并不代表我们要鼓吹“消除副作用”、“消除 mutation”；函数式的真正意义在于帮助程序员更好的带来我们想要的“副作用”、“mutation”，哪怕牺牲一些性能。**如果一个程序在运行之后什么也没有改变，那还有什么意义呢？

在这个问题上，“麻雀虽小五脏俱全”的 Scheme 提供了一个 `for-each` 函数：

```scheme
;;; procedure: (for-each procedure list1 list2 ...)
;;; returns: unspecified
(for-each display '(1 2 3)) ;; => （屏幕上输出）123
```

`for-each` 的实现[^3]较之 `map` 则显得更简洁一些：

```scheme
;;; am example implementation of `for-each` in Scheme
(define for-each
  (lambda (f ls . more)
    (do ([ls ls (cdr ls)] [more more (map cdr more)])
        ((null? ls))
      (apply f (car ls) (map car more)))))
```

# Common Lisp 中的 map

Common Lisp 虽然在设计方面受到 Scheme 的诸多影响，但是作为一门野心勃勃的、试图涵盖与统一所有 Lisp 方言的语言，Common Lisp 中和 `map` 有关的函数多达 9 个[^4]：

1. map
2. map-into
3. mapcar
4. mapc
5. maplist
6. mapl
7. mapcan
8. mapcon
9. maphash

接下来，我们按照上面列出的顺序逐个考察。首先给出其语法和示例用法，接着作出比较与讨论。

## map

```lisp
;;; Function MAP
;;; Syntax:
;;; map result-type function &rest sequences+ => result
(map 'list #'abs '(1 -2 3 -4 5 -6)) ;; => (1 2 3 4 5 6)
(map 'vector #'abs '(1 -2 3 -4 5 -6)) ;; => #(1 2 3 4 5 6)
(map 'vector #'char-code "abcdefg") ;; => #(97 98 99 100 101 102 103)
(map 'string #'code-char #(97 98 99 100 101 102 103)) ;; => "abcdefg"
```

这个 `map` 和 Scheme 中的 `map` 颇为相似。但是，第一个参数在此为返回类型，并且这个类型必须是序列（*Sequence*）的子类型；第二个参数才是映射函数，并且其参数的个数与接下来所提供的序列的个数应当一致。也就是说，这个 `map` 既可以用来映射列表，也可以用来映射数组。Common Lisp 语言本身在设计上的**正交性**在此也有所体现了。

值得注意的是，当第一个参数为 `nil` 的时候，`map` 便可以“模拟” Scheme 中 `for-each` 的行为：

```lisp
;;; map returns nil if result-type is nil,
;;; which means no result sequence is to be produced;
;;; in this case the function is invoked only for effect.
(map nil #'prin1 '(1 2 3)) ;; => 屏幕上输出 123，返回 NIL
```

最后要指出的是，在这里，各序列的长度不一定要完全一致，`map` 会以长度最短的序列为基准。我们姑且称之为“最短法则”。也就是说，如果参数中第一个序列长度为 10，第二个为 8，那么 `map` 在映射到各序列中第八个元素后就停止工作了：

```lisp
;;; when length of sequences is not the same ...
(map 'vector #'* '(1 2 3 4 5 6 7 8 9 10)
                 #(1 2 3 4 5 6 7 8))
;; => #(1 4 9 16 25 36 49 64)
```

更多信息请阅读 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node143.html#SECTION001820000000000000000) 以及 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_map.htm#map) 中的相关内容。

## map-into

```lisp
;;; Function MAP-INTO
;;; Syntax:
;;; map-into result-sequence function &rest sequences => result-sequence
(defvar *lst* (list 1 -2 3 -4 5 -6))
(map-into *lst* #'abs *lst*) ;; => (1 2 3 4 5 6)
*lst* ;; => (1 2 3 4 5 6)
(map-into *lst* #'* *lst* *lst*) ;; => (1 4 9 16 25 36)
*lst* ;; => (1 4 9 16 25 36)
```

`map-into` 和 `map` 很类似，并且都是可以在任意序列对象上操作的函数。但其区别在于，`map-into` 永远都会**改变一个现有序列的状态**，而不是像 `map` 一样会生成一个新的序列。[HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_map_in.htm#map-into) 上有一小段代码可以作为 `map-into` 的实现方式：

```lisp
;;; an example implementation of map-into
(defun map-into (result-sequence function &rest sequences)
  (loop for index below (apply #'min
                               (length result-sequence)
                               (mapcar #'length sequences))
     do (setf (elt result-sequence index)
              (apply function
                     (mapcar #'(lambda (seq) (elt seq index))
                             sequences))))
     result-sequence)
```

由此可见，

- 使用 *map-into* 的目的主要就在于其带来的“副作用”；
- *map-into* 的“迭代”次数取决于 *result-sequence* 和所有 *sequences* 中长度最小的，也就是说，如果最小长度是 *n*，那么在映射完第 *n* 次之后，*map-into* 就会停止工作。

另外要注意的是，如果 `result-sequence` 是一个拥有填充指针（*Fill Pointer*）的向量（*Vector*），那么 `map-into` 在工作时并不会考虑这个填充指针的大小；而在映射完成后，这个填充指针会被重新设置成映射函数被调用的次数：

```lisp
;;; CLtL2:
;;; If result-sequence is a vector with a fill pointer,
;;; the fill pointer is ignored when deciding how many iterations to perform,
;;; and afterwards the fill pointer is set to the number of times function was applied.
(defvar *vector* (make-array 5 :initial-element 0 :fill-pointer 2))
*vector* ;; => #(0 0)
(length *vector*) ;; => 2
(array-total-size *vector*) ;; => 5
(fill-pointer *vector*) ;; => 2
(map-into *vector* #'* '(1 2 3 4) #(1 2 3 4 5)) ;; => #(1 4 9 16)
(fill-pointer *vector*) ;; => 4
```

在这里也许有人就会发现了，`*vector*` 在初始化长度明明是 2，按照“最短法则”，`map-into`不应该迭代两次就停止工作了吗？让我们再来看一下语言标准 CLtL2 中的原文：

> If result-sequence and the other argument sequences are not all the same length, the iteration terminates when the shortest sequence is exhausted. – Section 14.2, CLtL2.

所以，虽然 `*vector*` 的长度一开始为 2，但是在映射完第二个元素后，`*vector*` 并没有 **exhausted[^5]**。上文中，HyperSpec 所给出的实现并未能很好体现这一点，故在此特别指明。更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_map_in.htm#map-into) 和 [CltL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node143.html#SECTION001820000000000000000) 中的相关内容。

## mapcar

```lisp
;;; Function MAPCAR
;;; Syntax:
;;; mapcar function &rest lists+ => result-list
(mapcar #'abs '(1 -2 3 -4 5 -6)) ;; => (1 2 3 4 5 6)
(mapcar #'* '(1 2 3) '(1 2 3)) ;; => (1 4 9)
(mapcar #'* '(1 2 3 4 5) '(1 2 3)) ;; => (1 4 9)
```

`mapcar` 只能操作于列表之上，所以它的行为和 Scheme 中的 `map` 完全类似。更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm#mapcar) 和 [CltL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node143.html#SECTION001820000000000000000) 中的相关内容。

## mapc

```lisp
;;; Function MAPC
;;; Syntax:
;;; mapc function &rest lists+ => list-1
(mapc #'prin1 '(1 2 3)) ;; => 屏幕上输出 123，返回 (1 2 3)
(mapc #'+ '(1 2 3) '(3 2 1)) ;; => (1 2 3)
```

`mapc` 只能操作于列表之上，且其行为几乎和 Scheme 的 `for-each` 一致，于是也和第一个参数为 `nil` 时的 `map` 类似。但不同的是，`mapc` 永远都会返回第一个列表的值，这也意味着 `mapc` 至少要接受三个参数。更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm#mapc) 和 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node90.html#SECTION001184000000000000000) 中的相关内容。

## maplist

```lisp
;;; Function MAPLIST
;;; Syntax:
;;; maplist function &rest lists+ => result-list
(maplist #'append '(1 2 3 4) '(1 2 3) '(1 2))
;; => ((1 2 3 4 1 2 3 1 2) (2 3 4 2 3 2))
```

`maplist` 只能操作于列表，理解它的关键在于，每一次映射函数得到的参数先是列表（们）本身，接着是列表（们）的 `cdr`，再接着是列表（们） `cdr` 的 `cdr`，直至在列表（们）碰到第一个 `nil` 后 `maplist` 停止工作。在此，我们不妨拥 Scheme 来做一个演示：

```lisp
;;; an example implementation of maplist in Scheme(define maplist(lambda (f lst . more)(if (null? more)(let map1 ([lst lst])(if (null? lst)'()(cons (f lst)(map1 (cdr lst)))))(let map-more ([lst lst][more more])(if (null? lst)'()(if (member '() more)'()(cons (apply f lst more)(map-more (cdr lst) (map cdr more)))))))))
```

更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm#maplist) 和 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node90.html#SECTION001184000000000000000) 中的相关内容。

## mapl

```lisp
;;; Function MAPL
;;; Syntax:
;;; mapl function &rest lists+ => list-1
(defvar *lst* nil)
(mapl #'(lambda (x) (push x *lst*)) '(1 2 3 4)) ;; => (1 2 3 4)
*lst* ;; => ((4) (3 4) (2 3 4) (1 2 3 4))
```

`mapl` 只能操作于列表之上，其行为和 `maplist` 类似，但是 `mapl` 并不会把每次的映射结果收集到一个新列表里，反而只会返回参数 `lists` 中的第一个列表。可以猜到的是，这个函数是为“副作用”而准备的。更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm#mapl) 和 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node90.html#SECTION001184000000000000000) 中的相关内容。

## mapcan

```lisp
;;; Function MAPCAN
;;; Syntax:
;;; mapcan function &rest lists+ => concatenated-results
(mapcan #'(lambda (x) (and (numberp x) (list x)))
        '(a 1 b c 3 4 d 5))
;;; => (1 3 4 5)
(mapcar #'(lambda (x) (and (numberp x) (list x)))
        '(a 1 b c 3 4 d 5))
;;; => (NIL (1) NIL NIL (3) (4) NIL (5))
(apply #'nconc '(NIL (1) NIL NIL (3) (4) NIL (5))) ;; => (1 3 4 5)
```

`mapcan` 只能操作于列表之上。简单来说，`mapcan` 是把 `mapcar` 的结果应用于 `nconc` 后的返回值：

```lisp
(defun mapcan (function list &rest more-lists)
  (apply #'nconc
         (apply #'mapcar function list more-lists)))
```

由于使用了 `nconc` 函数，`mapcan` 也随之带来了副作用。更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm#mapcan) 和 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node90.html#SECTION001184000000000000000) 中的相关内容。

## mapcon

```lisp
;;; Function MAPCON
;;; Syntax:
;;; mapcon function &rest lists+ => concatenated-results
(mapcon #'list (list 1 2 3 4))
;; => ((1 2 3 4) (2 3 4) (3 4) (4))
```

`mapcon` 同样也只能操作于列表之上，类似的，`mapcan` 是把 `maplist` 的结果应用于 `nconc` 后的返回值：

```lisp
(defun mapcon (function list &rest more-lists)
  (apply #'nconc
         (apply #'maplist list more-lists)))
```

同样的，由于使用了 `nconc` 函数，`mapcon` 也随之带来了副作用。更多信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_mapc_.htm#mapcon) 和 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node90.html#SECTION001184000000000000000) 中的相关内容。

## maphash

```lisp
;;; Function MAPHASH
;;; Syntax:
;;; maphash function hash-table => nil
(defvar *lst* '(a b c d e f g))
(defvar *table* (make-hash-table))
(dolist (sym *lst*)
  (setf (gethash sym *table*) (symbol-name sym)))
(maphash #'(lambda (k v) (format t "~A => ~S~%" k v))
         *table*)
;;; 屏幕输出：
;;; A => "A"
;;; B => "B"
;;; C => "C"
;;; D => "D"
;;; E => "E"
;;; F => "F"
;;; G => "G"
;;; 返回： NIL
```

`maphash` 是专门用来操作哈希表的函数。其第一个参数必定为一个双参函数，在每一次映射中，这个函数接受一对键值，并完成一次映射。对于这个映射函数所带来的潜在的副作用，语言规范中特别强调：

> If entries are added to or deleted from the hash table while a maphash is in progress, the results are unpredictable, with one exception: if the function calls remhash to remove the entry currently being processed by the function, or performs a setf of gethash on that entry to change the associated value, then those operations will have the intended effect. For example:
;;; Alter every entry in MY-HASH-TABLE, replacing the value with
;;; its square root.  Entries with negative values are removed.
(maphash #'(lambda (key val)
             (if (minusp val)
                 (remhash key my-hash-table)
                 (setf (gethash key my-hash-table) (sqrt val))))
                  my-hash-table)
– Section 16.1, CLtL2

也就是说，移除一对键值，或者修改当前键所对应的值是可以的，而其他的行为则就是未规范的了。值得一提的是，其实对于哈希表的迭代，Common Lisp 提供了更通用的 `with-hash-table-iterator`，以至于 `maphash` 其实可以基于它来实现：

```lisp
;;; Macro WITH-HASH-TABLE-ITERATOR
;;; Syntax:
;;; with-hash-table-iterator (name hash-table) declaration* form* => result*
(defun maphash (function hash-table)
  (with-hash-table-iterator (next-entry hash-table)
    (loop (multiple-value-bind (more key value) (next-entry)
            (unless more (return nil))
            (funcall function key value)))))
```

更多相关信息请阅读 [HyperSpec](http://www.lispworks.com/documentation/HyperSpec/Body/f_maphas.htm#maphash) 和 [CLtL2](http://www.cs.cmu.edu/Groups/AI/html/cltl/clm/node155.html) 中的相关内容。

# 总结

下面，我们从两个维度来观察这 9 个函数，并以此收结束本文。

## 操作对象

| 操作对象 | 函数名                                      |
| :------- | :------------------------------------------ |
| 哈希表   | maphash                                     |
| 列表     | mapcar, maplist, mapc, mapl, mapcan, mapcon |
| 序列     | map, map-into                               |

请注意，“列表”是“序列”的子类型，因此 `map` 与 `map-into` 具有更高的通用性（*General*）。

## 副作用

**首先需要说明，这里的“副作用”指的是这个函数到底是为了得到返回值，还是为了带来“副作用”。**换句话说，映射函数 `function` 可以尽管带来 `mutation`，但那极有可能是一种不良的编码风格；可在使用例如 `mapc` 的函数时，如果映射函数不带有任何“副作用”，那么它只会返回一个和参数一模一样的列表，这样的意义何在呢？

| 函数名   | 注解                                                         |
| :------- | :----------------------------------------------------------- |
| map      | 当第一个参数为 nil 时，可以认为目的是带来“副作用”            |
| map-into | 总是会修改一个现有序列的状态，有副作用                       |
| mapcar   | 无副作用                                                     |
| mapc     | 类似 Scheme 中的 for-each，有副作用                          |
| maplist  | 无副作用                                                     |
| mapl     | 原因类似 mapc，有副作用                                      |
| mapcan   | 可视为 mapcar 的延展，我们更想得到返回值，故认为无副作用[^6] |
| mapcon   | 可视为 maplist 的延展，我们更想得到返回值，故认为无副作用    |
| maphash  | 语言标准中只规范了两种可行的副作用，在此不特地做区分         |

所以，我的个人结论是：
| 区分                 | 函数名                                                         |
| :------------------- | :------------------------------------------------------------- |
| 为了带来副作用的函数 | mapc, mapl, map-into, 以及第一个参数为 nil 的 map              |
| 无副作用的函数       | mapcar, maplist, mapcan, mapcon, 以及第一个参数不为 nil 的 map |
| 只能带来特定的副作用 | maphash                                                        |

之所以要以“目的”来对“副作用”的含义进行说明，是希望在此能帮助读者更好的理解这些 `map` 操作符，理解语言设计者的用意。虽说“仁者见仁，智者见智”，但是我们还是希望在 Common Lisp 的编码风格上有着一定的规范，尤其是建议不要乱用、滥用这些操作符到不恰当的地方。

[^1]: 参见 Wikipedia, [https://en.wikipedia.org/wiki/Map_(higher-order_function)](https://en.wikipedia.org/wiki/Map_(higher-order_function))
[^2]: 参见 [Section 5.5](http://www.scheme.com/tspl4/control.html#./control:h5) Mapping and Folding, The Scheme Programming Language 4th Edition, R. Kent Dybvig.
[^3]: 同样参见 [Section 5.5](http://www.scheme.com/tspl4/control.html#./control:h5) Mapping and Folding, The Scheme Programming Language 4th Edition, R. Kent Dybvig.
[^4]: 这样的说法不算很严谨。毕竟，Scheme 中的 `map` 只能操作列表，而这里列出的这9个则能操作包括列表、数组，甚至哈希表。所以，这里“有关”的含义仅仅是名字里或者概念上和 `map` “有关”。
[^5]: 尽管如此，关于什么才是 **exhausted**，CLtL2 并没有做出定义。想在这个问题上探个究竟的朋友请参考 SBCL 中的[相关代码](https://github.com/sbcl/sbcl/blob/master/src/code/seq.lisp#L1270)，此处不做展开了。
[^6]: 基于上文对“副作用”的界定，这样的区分是有道理的。但是仍需注意的是，`mapcan` 以及接下来的 `mapcon` 都使用了破坏性函数 `nconc`，所以 `mapcan` 与 `mapcon` 也是有破坏性的。引用 CLtL2 中的话来说就是：*“Remember that nconc is a destructive operation, and therefore so are mapcan and mapcon; the lists returned by the function are altered in order to concatenate them.”*
