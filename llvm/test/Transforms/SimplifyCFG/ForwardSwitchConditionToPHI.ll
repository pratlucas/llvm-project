; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -forward-switch-cond=false -switch-range-to-icmp -S | FileCheck %s --check-prefix=NO_FWD
; RUN: opt < %s -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -forward-switch-cond=true  -switch-range-to-icmp -S | FileCheck %s --check-prefix=FWD

; PR10131

define i32 @forward_multiple(i32 %m) {
; NO_FWD-LABEL: @forward_multiple(
; NO_FWD-NEXT:  entry:
; NO_FWD-NEXT:    switch i32 [[M:%.*]], label [[SW_BB4:%.*]] [
; NO_FWD-NEXT:      i32 0, label [[RETURN:%.*]]
; NO_FWD-NEXT:      i32 1, label [[SW_BB1:%.*]]
; NO_FWD-NEXT:      i32 2, label [[SW_BB2:%.*]]
; NO_FWD-NEXT:      i32 3, label [[SW_BB3:%.*]]
; NO_FWD-NEXT:    ]
; NO_FWD:       sw.bb1:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       sw.bb2:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       sw.bb3:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       sw.bb4:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       return:
; NO_FWD-NEXT:    [[RETVAL_0:%.*]] = phi i32 [ 4, [[SW_BB4]] ], [ 3, [[SW_BB3]] ], [ 2, [[SW_BB2]] ], [ 1, [[SW_BB1]] ], [ 0, [[ENTRY:%.*]] ]
; NO_FWD-NEXT:    ret i32 [[RETVAL_0]]
;
; FWD-LABEL: @forward_multiple(
; FWD-NEXT:  entry:
; FWD-NEXT:    [[SWITCH:%.*]] = icmp ult i32 [[M:%.*]], 4
; FWD-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[SWITCH]], i32 [[M]], i32 4
; FWD-NEXT:    ret i32 [[SPEC_SELECT]]
;
entry:
  switch i32 %m, label %sw.bb4 [
  i32 0, label %sw.bb0
  i32 1, label %sw.bb1
  i32 2, label %sw.bb2
  i32 3, label %sw.bb3
  ]

sw.bb0:                                           ; preds = %entry
  br label %return

sw.bb1:                                           ; preds = %entry
  br label %return

sw.bb2:                                           ; preds = %entry
  br label %return

sw.bb3:                                           ; preds = %entry
  br label %return

sw.bb4:                                           ; preds = %entry
  br label %return

return:                                           ; preds = %entry, %sw.bb4, %sw.bb3, %sw.bb2, %sw.bb1
  %retval.0 = phi i32 [ 4, %sw.bb4 ], [ 3, %sw.bb3 ], [ 2, %sw.bb2 ], [ 1, %sw.bb1 ], [ 0, %sw.bb0 ]
  ret i32 %retval.0
}

; If 1 incoming phi value is a case constant of a switch, convert it to the switch condition:
; https://bugs.llvm.org/show_bug.cgi?id=34471
; This then subsequently should allow squashing of the other trivial case blocks.

define i32 @PR34471(i32 %x) {
; NO_FWD-LABEL: @PR34471(
; NO_FWD-NEXT:  entry:
; NO_FWD-NEXT:    switch i32 [[X:%.*]], label [[ELSE3:%.*]] [
; NO_FWD-NEXT:      i32 17, label [[RETURN:%.*]]
; NO_FWD-NEXT:      i32 19, label [[IF19:%.*]]
; NO_FWD-NEXT:      i32 42, label [[IF42:%.*]]
; NO_FWD-NEXT:    ]
; NO_FWD:       if19:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       if42:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       else3:
; NO_FWD-NEXT:    br label [[RETURN]]
; NO_FWD:       return:
; NO_FWD-NEXT:    [[R:%.*]] = phi i32 [ [[X]], [[IF19]] ], [ [[X]], [[IF42]] ], [ 0, [[ELSE3]] ], [ 17, [[ENTRY:%.*]] ]
; NO_FWD-NEXT:    ret i32 [[R]]
;
; FWD-LABEL: @PR34471(
; FWD-NEXT:  entry:
; FWD-NEXT:    switch i32 [[X:%.*]], label [[ELSE3:%.*]] [
; FWD-NEXT:      i32 17, label [[RETURN:%.*]]
; FWD-NEXT:      i32 19, label [[RETURN]]
; FWD-NEXT:      i32 42, label [[RETURN]]
; FWD-NEXT:    ]
; FWD:       else3:
; FWD-NEXT:    br label [[RETURN]]
; FWD:       return:
; FWD-NEXT:    [[R:%.*]] = phi i32 [ 0, [[ELSE3]] ], [ [[X]], [[ENTRY:%.*]] ], [ [[X]], [[ENTRY]] ], [ [[X]], [[ENTRY]] ]
; FWD-NEXT:    ret i32 [[R]]
;
entry:
  switch i32 %x, label %else3 [
  i32 17, label %return
  i32 19, label %if19
  i32 42, label %if42
  ]

if19:
  br label %return

if42:
  br label %return

else3:
  br label %return

return:
  %r = phi i32 [ %x, %if19 ], [ %x, %if42 ], [ 0, %else3 ], [ 17, %entry ]
  ret i32 %r
}

