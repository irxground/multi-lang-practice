
object Program {
  def TODO = throw new NotImplementedError

  // ---- ---- ---- define MyList ---- ---- ----
  sealed trait MyList[+T] {
    def foldRight[U](u: U)(f: (T, U) => U): U
    def foldLeft[U](u: U)(f: (U, T) => U): U
  }
  case object MyNil extends MyList[Nothing] {
    override def foldRight[U](u: U)(f: (Nothing, U) => U) = u
    override def foldLeft[U](u: U)(f: (U, Nothing) => U) = u
  }
  case class MyCons[+T](head: T, tail: MyList[T]) extends MyList[T] {
    override def foldRight[U](u: U)(f: (T, U) => U) = f(head, tail.foldRight(u)(f))
    override def foldLeft[U](u: U)(f: (U, T) => U) = tail.foldLeft(f(u, head))(f)
  }

  object MyList {
    def apply[T](xs: T*): MyList[T] = xs.foldRight(MyNil: MyList[T]){ MyCons(_, _) }

    def toString[T](list: MyList[T]): String =
      list.foldLeft(new java.lang.StringBuilder()){ (buff, item) =>
        buff.append(item).append(". ")
      }.toString()
  }

  // ---- ---- ---- define MyMonad ---- ---- ----
  trait Functoo[F[_]] {
    def map [A, B](f: F[A])(fun: A => B): F[B]
  }
  trait Monadaa[M[_]] extends Functoo[M] {
    def bind[A, B](m: M[A])(fun: A => M[B]): M[B]
  }

  def flat[M[_]: Monadaa, A](x: M[A], y: M[A])(f: (A, A) => A): M[A] = {
    val m = implicitly[Monadaa[M]]
    m.bind(x){ (xi: A) => m.map(y){ (yi: A) => f(xi, yi) } }
  }

  implicit class MonadaaOps[M[_], A](val left: M[A])(implicit m: Monadaa[M]) {
    def ***[B](right: M[B]): M[(A, B)] = {
      m.bind(left){ (x: A) => m.map(right){ (y: B) => (x, y) } }
    }
  }

  // ---- ---- ---- appl MyMonad ---- ---- ----
  implicit object MyList_is_Monadaa extends Monadaa[MyList] {
    def map[A, B](list: MyList[A])(mapFunc: A => B) =
      list.foldRight(MyNil: MyList[B]){ (x, y) => MyCons(mapFunc(x), y) }

    def bind[A, B](list: MyList[A])(f: A => MyList[B]): MyList[B] =
      list.foldRight(MyNil: MyList[B]){ (x, y) =>
        f(x).foldRight(y){ MyCons(_, _) }
      }
  }

  // ---- ---- ---- Entry Point ---- ---- ----
  def main(args: Array[String]) {
    val one = MyList(1,  2,  3)
    val ten = MyList(10, 20, 30)
    println(MyList.toString( flat(one, ten)(_ + _) ))
    println(MyList.toString(one *** ten ))
  }
}

