#include <functional>
#include <iostream>

/* ---- ---- ---- define MyList ---- ---- ---- */
template <class T> class List {
  public:
  T value;
  List<T> *next;

  List(T v, List<T> *n) : value(v), next(n) { }
  ~List() {
    if (next != nullptr) {
      delete next;
      next = nullptr;
    }
  }

  template<class U> U foldRight (U seed, std::function<U(T, U)> f) {
    if (next == nullptr)
      return seed;
    else
      return f(value, next->foldRight(seed, f));
  }

  std::ostream &writeBuff(std::ostream &out) {
    out << value << ". ";
    if (next == nullptr)
      return out;
    else
      return next->writeBuff(out);
  }
};

template<class T> List<T> *cons(T item, List<T> *next) {
  return new List<T>(item, next);
};

/* ---- ---- ---- define Monadaa and use ---- ---- ---- */

template<template<class> class M> class Monadaa {
  template<class A, class B> static M<B> map (M<A> ma, std::function<B(A)> f);
  template<class A, class B> static M<B> bind (M<A> ma, std::function<M<B>(A)> f);
};

template<
  template<class> class M,
  class A,
  class B,
  class X
>
M<X> flat (M<A> ma, M<B> mb, std::function<X(A, B)> f) {
  return M.bind(ma, [](A a) {
    return M.map(mb, [&a](B b) {
      return f(a, b);
    });
  });
}

/* ---- ---- ---- List is Monadaa ---- ---- ---- */
template <> class Monadaa<List> {
  template<class A, class B> static List<B> map(List<A>, std::function<B(A)> f) {
    return nullptr;
  }

  template<class A, class B> static List<B> bind(List<A>, std::function<List<B>(A)> f) {
    return nullptr;
  }
};

/* ---- ---- ---- Entry point ---- ---- ---- */

int main () {
  auto *one = cons(1, cons(2, cons<int>(3, nullptr)));
  one->writeBuff(std::cout) << std::endl;

  delete one;
  return 0;
}

