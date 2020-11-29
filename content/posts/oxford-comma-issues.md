+++
title = "The Oxford comma and its Issues"
date = 2018-03-24
tags = ["essay"]
+++

{{< youtube P_i1xk07o4g >}}

During recent work, we have encountered an interesting concept called [Oxford comma](https://en.wiktionary.org/wiki/Oxford_comma) (also called a Harvard comma, or a serial comma, or series comma). As a native Chinese speaker, I have neither met it nor expected it ever before. There are already enough other aspects that are of inherent ambiguity and implicitness of my native language (or any other natural language), but the Oxford comma is definitely a problem for languages that are not written in [scriptio continua](https://en.wikipedia.org/wiki/Scriptio_continua).

# Definition

![Oxford Comma](/img/the-oxford-comma.jpg)

An Oxford comma is a comma placed immediately before the [coordinating conjunction](https://en.wikipedia.org/wiki/Grammatical_conjunction#Coordinating_conjunctions) (usually *and* or *or*) in a series of three or more terms[^1]. For example, a list of three items may be punctuated either as **x, y and z** or **x, y, and z**. Thus in the latter sentence, the last comma before *and* ([conj](http://universaldependencies.org/en/dep/conj.html)) is the Oxford comma.

# Usage and Style Guides

Whether to use the Oxford comma or not is totally a stylistic choice, which means it is absolutely up to the authors. However, if you are drafting materials for, e.g. academic purposes, you might want to know if there is any guide specifically discussing the usage of the Oxford comma. Please read carefully through the sections of *[Usage](Recommendations%20by%20style%20guides)* and *[Recommendations by style guides](Recommendations%20by%20style%20guides)* from its Wikipedia page for more information.

# Ambiguity

Resolving the ambiguity is a classic and intriguing task for computational linguists or people from the NLP community. Usually, ambiguities can arise from the uses of compound nouns, [endophoras](https://en.wiktionary.org/wiki/endophora) or just missing information regarding contexts. However, the use of Oxford commas may also either resolve or bring ambiguities. We will soon see it is actually a logic problem and the very “fragility” of our natural language.

## Resolving Ambiguity

Consider this common example that looks from a book’s dedication:

> To my parents, David and Humpty Dumpty.

Without the Oxford comma, the sentence above could be interpreted as stating that this book is dedicated to your parents who are David and Humpty Dumpty. If we put an Oxford comma in the right place:

> To my parents, David, and Humpty Dumpty.

It removes the ambiguity such that “my parents”, “David” and “Humpty Dumpty” are three isolated items thus no confusion anymore.

## Creating Ambiguity

Interestingly, consider an example that looks from a book’s dedication:

> To my father, David, and Humpty Dumpty.

In this case, the second item “David” will create the ambiguity such that it can mean “father” or just “David”. The subtlety here is “David” can be an appositive referring to “father” so that the sentence actually only contains two unique items instead of three. If we remove the Oxford comma:

> To my father, David and Humpty Dumpty.

then the ambiguity will be removed as well, since “David” here cannot be read as in apposition to “father” anymore.

## Irreconcilable Ambiguity

Finally, we will introduce a somewhat pessimistic situation here. That is, sometimes, it seems the ambiguity just cannot be harmonised. Consider this example:

> To my mom and aunt, Maria and Sophia.

It is ambiguous because we cannot determine how many people are there indeed. “Maria and Sophia” can be in apposition to “mom and aunt” as an entirety. So there can be either four people mentioned or just two. However, even if we add up an Oxford comma:

> To my mom and aunt, Maria, and Sophia.

still, the ambiguity remains. In this case, “Maria” can be an appositive referring to “aunt”. So we will be wondering if it’s mentioning four people or three instead.

This is rather embarrassing. For both authors and readers, we need to be aware of this phenomenon. On the other hand, there are of course many ways to remove those ambiguities — by rewriting the sentence into another form. Even further, its Wikipedia page even records a [list](https://en.wikipedia.org/wiki/Serial_comma#In_general) of general rules for avoiding creating ambiguities[1]:

- The list **x**, **y** and **z** is unambiguous if **y** and **z** cannot be read as in apposition to **x**.
- Equally, **x**, **y**, and **z** is unambiguous if **y** cannot be read as in apposition to **x**.
- If neither **y** nor **y**[,] and **z** can be read as in apposition to **x**, then both forms of the list are unambiguous; but if both **y** and **y** and **z** can be read as in apposition to **x**, then both forms of the list are ambiguous.
- **x** and **y** and **z** is unambiguous if **x** and **y** and **y** and **z** cannot both be grouped.

Those strategic rules are the reason why we considered it is actually “a logic problem” at the beginning of this section. I am curious how computer algorithms resolve this type of ambiguity brought by the usage of Oxford comma, although humans can justify the logic and rewrite the sentences into right forms.

[^1]: Serial comma, Wikipedia, [https://en.wikipedia.org/wiki/Serial_comma](https://en.wikipedia.org/wiki/Serial_comma)