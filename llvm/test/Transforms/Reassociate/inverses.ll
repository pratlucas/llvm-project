; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=reassociate,dce -S | FileCheck %s

; (A&B)&~A == 0
define i32 @test1(i32 %a, i32 %b) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 0
;
  %t2 = and i32 %b, %a
  %t4 = xor i32 %a, -1
  %t5 = and i32 %t2, %t4
  ret i32 %t5
}

define <2 x i32> @not_op_vec_poison(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: @not_op_vec_poison(
; CHECK-NEXT:    ret <2 x i32> zeroinitializer
;
  %t2 = and <2 x i32> %b, %a
  %t4 = xor <2 x i32> %a, <i32 -1, i32 poison>
  %t5 = and <2 x i32> %t2, %t4
  ret <2 x i32> %t5
}

; A&~A == 0
define i32 @test2(i32 %a, i32 %b) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    ret i32 0
;
  %t1 = and i32 %a, 1234
  %t2 = and i32 %b, %t1
  %t4 = xor i32 %a, -1
  %t5 = and i32 %t2, %t4
  ret i32 %t5
}

; (b+(a+1234))+-a -> b+1234
define i32 @test3(i32 %b, i32 %a) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[T5:%.*]] = add i32 [[B:%.*]], 1234
; CHECK-NEXT:    ret i32 [[T5]]
;
  %t1 = add i32 %a, 1234
  %t2 = add i32 %b, %t1
  %t4 = sub i32 0, %a
  %t5 = add i32 %t2, %t4
  ret i32 %t5
}

; (b+(a+1234))+~a -> b+1233
define i32 @test4(i32 %b, i32 %a) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[T5:%.*]] = add i32 [[B:%.*]], 1233
; CHECK-NEXT:    ret i32 [[T5]]
;
  %t1 = add i32 %a, 1234
  %t2 = add i32 %b, %t1
  %t4 = xor i32 %a, -1
  %t5 = add i32 %t2, %t4
  ret i32 %t5
}

