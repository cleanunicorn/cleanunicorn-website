+++
title = "RSA Encryption"
date = "2019-01-29T12:33:35+02:00"
draft = false
+++

I wanted to learn more about cryptography and it is easier to learn if I read about it, I do it by hand or write some code and I explain it to someone. That someone is you.

So I started with RSA which is a very common encryption. [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) stands for Rivest–Shamir–Adleman which are the 3 people who designed this public-key cryptosystem and also it is the first public-key encryption.

Let's start with an example and this is actually easier to understand if you take a piece of paper and do the calculation as you read.

## Example

We just want to encrypt a single character, a single letter, the letter `B`. We first have to transform this letter into a number, the number `2`.

We chose the number 2 for the letter B because we consider

- A = 1
- B = 2
- C = 3
- ...

The message that we are encoding is $m$

$m=2$

The `public_key` and `private_key` we already know and we will understand how to use them and then we are going to understand how to create the keys.

Our `public_key`, also known as encryption key consists of 2 numbers:

- $e = 5$ public (or encryption) exponent
- $n = 14$ modulus

The `private_key`, also known as decryption key is made of:

- $d = 11$ private (or decryption) exponent
- $n = 14$ modulus

## Encryption

These are the important parts for encryption.

What we know

- $m = 4$ message to be encrypted
- $e = 5$ exponent of public key
- $n = 14$ modulus of public key

What we need to compute

- $c$ encrypted cypher text

### To encrypt some data you need to compute

$m^e \mod n = c$

In our case

$2^5 mod 14 = 4$

## Decryption

These are the important parts for decryption

What we know

- $c = 4$ - cyphertext aka encrypted message (computed above)
- $d = 11$ - exponent of private key
- $n = 14$ - modulus of private key

What we need to compute

- $m$ - decrypted message

### To decrypt some data you need to compute

$c^d \mod n = m$

In our case

$4^{11} mod 14 = 2$

---

Now we understand the basic process to encrypt and decrypt data, we have to find out how to generate the `public_key` and the `private_key`.

## Compute the encryption and decryption keys

We start by picking $2$ prime numbers $p$ and $q$

$p = 2$

$q = 7$

We compute the $n$ modulus which will be part of both private and public keys

$p * q = n$

That means

$n = 14$

And we also need to compute $\phi(n)$ which we will need later

$(p - 1) * (q - 1) = \phi(n)$

$(2 - 1) * (7 - 1) = 6$

$\phi(n) = 6$

### Public key

We need to pick an $e$ that fulfills these conditions:

$e \left\\{
        \begin{array}{ll}
            1 < e < \phi(n) \\\\ e \perp n\\\\ e \perp \phi(n)\\\\
        \end{array}
    \right.$

In this case $\perp$ means coprime, meaning it does not have any divisors in common with $n$ or with $\phi(n)$.

In other words
- $e$ is greater than $1$ and lower than $\phi(n)$
- $\gcd(e, n) = 1$
- $\gcd(e, \phi(n)) = 1$

Where $\gcd$ denotes the [greatest common divisor](https://en.wikipedia.org/wiki/Greatest_common_divisor).

The numbers that are greater than $1$ and lower than $\phi(n)$ are:

$2$ $3$ $4$ $5$

Out of these numbers, the only number that is coprime with 14 and 6 is

$\bcancel2$ $\bcancel3$ $\bcancel4$ $5$

That means

$e = 5$

This makes our **public_key** $(e = 5, n = 14)$

### Private key

We need to pick a $d$ such as

$(d*e)\mod \phi(n) = 1$

In this case we need to do a little bit of work. So a simple python script should be able to solve this

```python
e = 5
phi_n = 6
for i in range(1,50):
    if (i * e) % phi_n == 1:
        print("Found {}".format(i))
```

Which outputs

```
Found 5
Found 11
Found 17
Found 23
Found 29
Found 35
Found 41
Found 47
```

We can pick any result, I decided to pick $d = 11$.

Which makes our **private key** $(d = 11, n = 14)$

## Conclusion

We got our keys:

- public key $(e = 5, n = 14)$
- private key $(d = 11, n = 14)$

And we learned how to derive the encryption and decryption keys.

In practice things are a bit harder, you need to pick huge prime numbers and the bigger they are, the stronger your cyper is. But it's super important to understand how to do this and it's fairly easy to do with small numbers.
