; RUN: mlir-translate -import-llvm -split-input-file %s | FileCheck %s

; CHECK-LABEL: llvm.func @somefunc(i32, !llvm.ptr)
declare void @somefunc(i32, ptr)

; CHECK-LABEL: llvm.func @test_call_arg_attrs_direct(
; CHECK-SAME:    %[[VAL_0:.*]]: i32,
; CHECK-SAME:    %[[VAL_1:.*]]: !llvm.ptr)
define void @test_call_arg_attrs_direct(i32 %0, ptr %1) {
  ; CHECK: llvm.call @somefunc(%[[VAL_0]], %[[VAL_1]]) : (i32, !llvm.ptr {llvm.byval = i64}) -> ()
  call void @somefunc(i32 %0, ptr byval(i64) %1)
  ret void
}

; CHECK-LABEL: llvm.func @test_call_arg_attrs_indirect(
; CHECK-SAME:    %[[VAL_0:.*]]: i16,
; CHECK-SAME:    %[[VAL_1:.*]]: !llvm.ptr
define i16 @test_call_arg_attrs_indirect(i16 %0, ptr %1) {
  ; CHECK: llvm.call tail %[[VAL_1]](%[[VAL_0]]) : !llvm.ptr, (i16 {llvm.noundef, llvm.signext}) -> (i16 {llvm.signext})
  %3 = tail call signext i16 %1(i16 noundef signext %0)
  ret i16 %3
}

; // -----

%struct.S = type { i8 }

; CHECK-LABEL: @t
define void @t(i1 %0) #0 {
  %3 = alloca %struct.S, align 1
  ; CHECK-NOT: llvm.call @z(%1) {no_unwind} : (!llvm.ptr) -> ()
  ; CHECK: llvm.call @z(%1) : (!llvm.ptr) -> ()
  call void @z(ptr %3)
  ret void
}

define linkonce_odr void @z(ptr %0) #0 {
  ret void
}

attributes #0 = { nounwind }
