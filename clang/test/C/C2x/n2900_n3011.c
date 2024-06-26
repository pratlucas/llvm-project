// RUN: %clang_cc1 -std=c2x -fsyntax-only -Wpre-c2x-compat -verify=compat %s
// RUN: %clang_cc1 -std=c17 -fsyntax-only -pedantic -Wno-comment -verify=pedantic %s

/* WG14 N2900: yes
 * Consistent, Warningless, and Intuitive Initialization with {}
 */

/* WG14 N3011: yes
 * Consistent, Warningless, and Intuitive Initialization with {}
 */
void test(void) {
  struct S { int x, y; } s = {}; // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                                    pedantic-warning {{use of an empty initializer is a C23 extension}}
  int i = {}; // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                                  pedantic-warning {{use of an empty initializer is a C23 extension}}
  int j = (int){}; // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                      pedantic-warning {{use of an empty initializer is a C23 extension}}

  // C2x 6.7.10p4 says, in part: An array of unknown size shall not be
  // initialized by an empty initializer.
  // However, Clang allows zero-sized arrays as an extension in both C and C++,
  // and this initialization form will deduce the array extent as zero. Given
  // that we support empty initialization of an unbounded array in C++, we also
  // support it in C.
  int unknown_size[] = {}; // pedantic-warning {{zero size arrays are an extension}} \
                              pedantic-warning {{use of an empty initializer is a C23 extension}} \
                              compat-warning {{use of an empty initializer is incompatible with C standards before C23}}
  int vla[i] = {}; // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                      pedantic-warning {{use of an empty initializer is a C23 extension}}
  // C99 6.5.2.5 Compound literals constraint 1: The type name shall specify an
  // object type or an array of unknown size, but not a variable length array
  // type.
  int *compound_literal_vla = (int[i]){}; // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                                             pedantic-warning {{use of an empty initializer is a C23 extension}}\
                                             compat-error {{compound literal cannot be of variable-length array type}} \
                                             pedantic-error {{compound literal cannot be of variable-length array type}}\


  struct T {
	int i;
    struct S s;
  } t1 = { 1, {} }; // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                       pedantic-warning {{use of an empty initializer is a C23 extension}}

  struct T t2 = {
    1, {
      2, {} // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
               pedantic-warning {{use of an empty initializer is a C23 extension}}
    }
  };

  struct T t3 = {
    (int){}, // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                pedantic-warning {{use of an empty initializer is a C23 extension}}
    {} // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
          pedantic-warning {{use of an empty initializer is a C23 extension}}
  };

  // Ensure that zero initialization does what you'd expect in a constant expr.
  // FIXME: the "not an ICE" warning is incorrect for C2x, but we don't yet
  // implement WG14 N3038.
  _Static_assert((int){} == 0, "what?");  // compat-warning {{use of an empty initializer is incompatible with C standards before C23}} \
                                             pedantic-warning {{use of an empty initializer is a C23 extension}} \
                                             pedantic-warning {{expression is not an integer constant expression; folding it to a constant is a GNU extension}}
}

