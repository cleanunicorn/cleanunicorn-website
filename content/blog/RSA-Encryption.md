+++
title = "RSA Encryption"
date = "2019-01-26T13:28:09+02:00"
draft = false
+++

# RSA Encryption
With small numbers

Our text to encrypt is just the letter `B`. We can transform the letter `B` into the number 2. From now on, the number 2 will represent the letter `B`.

> We chose the number 2 for the letter B because we consider
> - A = 1
> - B = 2
> - C = 3
> ...


The message that we are encoding is


```python
message = 2
```

Our encryption key (`public_key`) is made of
- `e = 5` public (or encryption) exponent
- `n = 14` modulus


```python
public_key = {'e': 5, 'n': 14}
```

The decryption key (`private_key`) is made of
- `d = 11` private (or decryption) exponent
- `n = 14` modulus


```python
private_key = {'d': 11, 'n': 14}
```

## Encryption

- $m$ message to be encrypted
- $e$ exponent of public key
- $n$ modulus of public key
- $c$ encrypted cypher text

**To encrypt some data you need to compute**

$m^e \mod n = c$

**In our example**

$2^5 mod 14 = 4$


```python
# Compute the encrypted message (cypher text)
encrypted_message = message ** public_key['e'] % public_key['n']

# Display that
encrypted_message
```




    4



## Decryption

- $c$ cyphertext aka encrypted message (computed above)
- $d$ exponent of private key
- $n$ modulus of private key
- $m$ decrypted message

### To decrypt some data you need to compute

$c^d \mod n = m$

**In our example**

$4^{11} mod 14 = 2$


```python
# Compute the decrypted text
decrypted_text = encrypted_message ** private_key['d'] % private_key['n']

# Display decrypted text
decrypted_text
```




    2



## How to generate public and private keys

Now you understand how to encrypt and decrypt a message if you have the private and public keys but you also have to learn how to generate the public and private keys.

We start by picking 2 prime numbers $p$ and $q$


```python
p = 2
q = 7

p, q
```




    (2, 7)



We compute the `n` modulus which will be part of both private and public keys


```python
n = p * q

n
```




    14



And we also need to compute $\phi(n)$


```python
phi_n = (p - 1) * (q - 1)


phi_n
```




    6



### Public key

We need to pick an $e$ that fulfills these conditions:

![Long horses](/images/blog/rsa-tutorial/e-conditions.png)

In this case $\perp$ means coprime, meaning it does not have any divisors in common with $n$ or with $\phi(n)$.

In other words
- $e$ is greater than $1$ and lower than $\phi(n)$
- $gcd(e, n) = 1$
- $gcd(e, \phi(n)) = 1$

Where $\gcd$ denotes the greatest common divisor.

The numbers that are greater than $1$ and lower than $\phi(n)$ are

$2$ $3$ $4$ $5$

Out of these numbers, the only number that is coprime with 14 and 6 is

$\bcancel2$ $\bcancel3$ $\bcancel4$ $5$

That means $e = 5$

That means the **public_key** is $(e = 5, n = 14)$

### Private key
