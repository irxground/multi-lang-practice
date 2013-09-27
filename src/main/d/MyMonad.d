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

  override const string toString() {
    auto str = to!(string)(item) ~ ". ";
    if (next is null)
      return str;
    else
      return str ~ next.toString();
  }

  static const List!(T) build(T[] items ...) {
    List!(T) list = null;
    foreach_reverse (T t; items)
      list = new List!(T)(t, list);
    return list;
  }

  const U foldRight(U)(U seed, U delegate(T, U) f) {
    if (next !is null)
      seed = next.foldRight(seed, f);
    return f(item, seed);
  }

  const U foldLeft(U)(U seed, U delegate(U, T) f) {
    auto v = f(seed, item);
    if (next is null)
      return v;
    return next.foldLeft(v, f);
  }

  List!(T) opAdd(List!(T) that) {
    return foldRight(that, (T item, List!(T) next) {
      return new List!(T)(item, next);
    });
  }
}

/* ---- ---- ---- define Monadaa & use ---- ---- ---- */
interface Monadaa(alias containerType) {
  alias containerType T;
  static T!(B)  map(A, B)(T!(A) from, B delegate(A) f);
  static T!(B) bind(A, B)(T!(A) from, T!(B) delegate(A) f);
}

template UseMonadaa(alias M) {
  M.T!(X) flat(A, B, X)(M.T!(A) xs, M.T!(B) ys, X delegate(A, B) f) {
    return M.bind(xs, (A x) {
      return M.map(ys, (B y) {
        return f(x,y);
      });
    });
  }
}

/* ---- ---- ---- apply Monadaa ---- ---- ---- */

class ListIsMonadaa : Monadaa!(List) {
  static List!(B) map(A, B)(List!(A) from, B delegate(A) f) {
    return null;
  }

  static List!(B) bind(A, B)(List!(A) from, List!(B) delegate(A) f) {
    return null;
  }
}

/* ---- ---- ---- define List ---- ---- ---- */

void main() {
  auto one = List!(int).build( 1,  2,  3);
  auto ten = List!(int).build(10, 20, 30);
  auto plus = (int a, int b){ return a + b; };
  writeln(one + ten);
  auto flatten = UseMonadaa!(ListIsMonadaa).flat(one, ten, plus);
}


