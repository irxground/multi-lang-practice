import std.stdio;
import std.conv;

/* ---- ---- ---- define List ---- ---- ---- */
class List(T) {
  const T item;
  const List!(T) next;
  this(T item, List!(T) next) {
    this.item = item;
    this.next = next;
  }

  static const List!(T) build(T[] items ...) {
    List!(T) list = null;
    foreach_reverse (T t; items)
      list = new List!(T)(t, list);
    return list;
  }

  U foldRight(U)(U seed, U delegate(T, U) f) const {
    if (next !is null)
      seed = next.foldRight(seed, f);
    return f(item, seed);
  }

  const U foldLeft(U)(U seed, U delegate(U, T) f) const {
    auto v = f(seed, item);
    if (next is null)
      return v;
    return next.foldLeft(v, f);
  }

  List!(T) opAdd(List!(T) that) const {
    return foldRight!(List!(T))(that, (item, next) => new List!(T)(item, next));
  }

  override const string toString() const {
    return foldLeft!(string)("", (str, item) => str ~ to!(string)(item) ~ ". ");
  }
}

/* ---- ---- ---- define Monadaa & use ---- ---- ---- */
interface Monadaa(alias containerType) {
  alias containerType T;
  static T!(B) map(A, B)(T!(A) from, B delegate(A) f);
  static T!(B) bind(A, B)(T!(A) from, T!(B) delegate(A) f);
}

template UseMonadaa(alias M) {
  M.T!(X) flat(A, B, X)(M.T!(A) as, M.T!(B) bs, X delegate(A, B) f) {
    return M.bind!(A, X)(as, a => M.map!(B, X)(bs, b => f(a, b)));
  }
}

/* ---- ---- ---- apply Monadaa ---- ---- ---- */
class ListIsMonadaa : Monadaa!(List) {
  static List!(T2) map(T1, T2)(List!(T1) from, T2 delegate(T1) f) {
    return from.foldRight!(List!(T2))(null, (item, l) => new List!(T2)(f(item), l));
  }

  static List!(T2) bind(T1, T2)(List!(T1) from, List!(T2) delegate(T1) f) {
    return from.foldRight!(List!(T2))(null, (item, l) => f(item) + l);
  }
}

/* ---- ---- ---- define List ---- ---- ---- */
void main() {
  alias UseMonadaa!(ListIsMonadaa) mod;
  auto one = List!(int).build(1, 2, 3);
  auto ten = List!(int).build(10, 20, 30);
  writeln(mod.flat!(int, int, int)(one, ten, (a, b) => a + b));
}

