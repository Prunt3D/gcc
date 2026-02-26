--  { dg-do compile }

procedure Dimensions3 is

   type Dimensioned_Float is new Long_Float
   with
     Dimension_System =>
       ((Unit_Name => Millimeter, Unit_Symbol => "mm", Dim_Symbol => "Length"),
        (Unit_Name => Second, Unit_Symbol => "s", Dim_Symbol => "Time"));

   subtype Length is Dimensioned_Float
   with
     Dimension => (Symbol => "mm", Millimeter => 1, others => 0),
     Annotate  => (Prunt_Config, Unit, "mm");

   subtype Time is Dimensioned_Float
   with
     Dimension => (Symbol => "s", Second => 1, others => 0),
     Annotate  => (Prunt_Config, Unit, "s");

   pragma Warnings (Off, "assumed to be");
   mm : constant Length := 1.0;
   s  : constant Time := 1.0;
   pragma Warnings (On, "assumed to be");

   subtype Velocity is Dimensioned_Float
   with
     Dimension =>
       (Symbol => "mm/s", Millimeter => 1, Second => -1);

   type Velocity_In_Record is record
      V1 : Velocity range 0.0 * mm / s .. 1.0 * mm / s := 0.5 * mm / s;
      V2 : Velocity range 0.0          .. 1.0 * mm / s := 0.5 * mm / s;
      V3 : Velocity range 0.1          .. 1.0 * mm / s := 0.5 * mm / s;
      --  { dg-warning "assumed to be \"0.1 * mm/s\"" "" { target *-*-* } 34 }
      V4 : Velocity range 0.0 * mm / s .. 1.0          := 0.5 * mm / s;
      --  { dg-warning "assumed to be \"1.0 * mm/s\"" "" { target *-*-* } 36 }
      V5 : Velocity range 0.0 * mm / s .. 1.0 * mm / s := 0.5         ;
      --  { dg-warning "assumed to be \"0.5 * mm/s\"" "" { target *-*-* } 38 }
      V6 : Velocity range 0.0 * mm     .. 1.0 * mm / s := 0.5 * mm / s;
      --  { dg-error "dimensions mismatch in component declaration" "" { target *-*-* } 40 }
      --  { dg-error "expected dimension \[Length.Time\*\*(-1)\]*"  "" { target *-*-* } 40 }
      V7 : Velocity range 0.0 * mm / s .. 1.0 * mm     := 0.5 * mm / s;
      --  { dg-error "dimensions mismatch in component declaration" "" { target *-*-* } 43 }
      --  { dg-error "expected dimension \[Length.Time\*\*(-1)\]*"  "" { target *-*-* } 43 }
      V8 : Velocity range 0.0 * mm / s .. 1.0 * mm / s := 0.5 * mm    ;
      --  { dg-error "dimensions mismatch in component declaration" "" { target *-*-* } 46 }
      --  { dg-error "expected dimension \[Length.Time\*\*(-1)\]*"  "" { target *-*-* } 46 }
      V9 : Velocity range 0.0 * mm / s .. 1.0 * mm / s := 0.0         ;
      V0 : Velocity range 0.0 * mm / s .. 0.0          := 0.0         ;
   end record;

   subtype T1 is Velocity range 0.0 * mm / s .. 1.0 * mm / s;
   subtype T2 is Velocity range 0.0          .. 1.0 * mm / s;
   subtype T3 is Velocity range 0.1          .. 1.0 * mm / s;
   --  { dg-warning "assumed to be \"0.1 * mm/s\"" "" { target *-*-* } 55 }
   subtype T6 is Velocity range 0.0 * mm     .. 1.0 * mm / s;
   --  { dg-error "dimensions mismatch in subtype declaration"  "" { target *-*-* } 57 }
   --  { dg-error "expected dimension \[Length.Time\*\*(-1)\]*" "" { target *-*-* } 57 }
   subtype T7 is Velocity range 0.0 * mm / s .. 1.0 * mm    ;
   --  { dg-error "dimensions mismatch in subtype declaration"  "" { target *-*-* } 60 }
   --  { dg-error "expected dimension \[Length.Time\*\*(-1)\]*" "" { target *-*-* } 60 }
   subtype T9 is Velocity range 0.0 * mm / s .. 1.0 * mm / s;
   subtype T0 is Velocity range 0.0 * mm / s .. 0.0         ;

   A : Velocity_In_Record;
begin
   pragma Assert (A.V1 = 0.5 * mm / s);
end Dimensions3;
