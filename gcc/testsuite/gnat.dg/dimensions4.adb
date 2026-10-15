--  { dg-do run }
--  { dg-options "-gnata -O0 -fdump-tree-original" }

with Ada.Numerics;

procedure Dimensions4 is
   type Single is new Float with
     Dimension_System =>
       ((Unit_Name => Metre, Unit_Symbol => 'm', Dim_Symbol => 'L'),
        (Unit_Name => Second, Unit_Symbol => 's', Dim_Symbol => 'T'));
   subtype Single_Length is Single with
     Dimension => (Symbol => 'm', Metre => 1, others => 0);
   subtype Single_Area is Single with
     Dimension => (Symbol => "m2", Metre => 2, others => 0);

   type Double is new Long_Float with
     Dimension_System =>
       ((Unit_Name => Metre, Unit_Symbol => 'm', Dim_Symbol => 'L'),
        (Unit_Name => Second, Unit_Symbol => 's', Dim_Symbol => 'T'));
   subtype Double_Length is Double with
     Dimension => (Symbol => 'm', Metre => 1, others => 0);
   subtype Double_Area is Double with
     Dimension => (Symbol => "m2", Metre => 2, others => 0);
   subtype Double_Volume is Double with
     Dimension => (Symbol => "m3", Metre => 3, others => 0);
   subtype Double_Inverse_Length is Double with
     Dimension => (Symbol => "1/m", Metre => -1, others => 0);

   type Extended is new Long_Long_Float with
     Dimension_System =>
       ((Unit_Name => Metre, Unit_Symbol => 'm', Dim_Symbol => 'L'),
        (Unit_Name => Second, Unit_Symbol => 's', Dim_Symbol => 'T'));
   subtype Extended_Length is Extended with
     Dimension => (Symbol => 'm', Metre => 1, others => 0);
   subtype Extended_Area is Extended with
     Dimension => (Symbol => "m2", Metre => 2, others => 0);

   function Root_F (X : Single_Area) return Single_Length is
     (X ** (1/2));
   function Root_LF (X : Double_Area) return Double_Length is
     (X ** (1/2));
   function Root_LLF (X : Extended_Area) return Extended_Length is
     (X ** (1/2));
   function Cube_Root (X : Double_Volume) return Double_Length is
     (X ** (1/3));
   function Inverse_Root (X : Double_Area) return Double_Inverse_Length is
     (X ** (-1/2));
   function Dimensionless_Root (X : Double) return Double is
     (X ** (1/2));

   pragma Warnings (Off, "assumed to be");
   M_F   : constant Single_Length := 1.0;
   M_LF  : constant Double_Length := 1.0;
   M_LLF : constant Extended_Length := 1.0;
   pragma Warnings (On, "assumed to be");

   Result : Double_Length;
   Inverse_Result : Double_Inverse_Length;
begin
   pragma Assert (Root_F (4.0 * M_F * M_F) = 2.0 * M_F);
   pragma Assert (Root_LF (4.0 * M_LF * M_LF) = 2.0 * M_LF);
   pragma Assert (Root_LLF (4.0 * M_LLF * M_LLF) = 2.0 * M_LLF);
   pragma Assert
     (abs (Cube_Root (8.0 * M_LF ** 3) - 2.0 * M_LF) < 0.00001 * M_LF);
   pragma Assert (Inverse_Root (4.0 * M_LF * M_LF) = 0.5 / M_LF);
   pragma Assert (Dimensionless_Root (4.0) = 2.0);
   pragma Assert (Root_LF (0.0 * M_LF * M_LF) = 0.0 * M_LF);

   --  Preserve the elementary functions' domain checks.

   begin
      Result := Root_LF (-1.0 * M_LF * M_LF);
      raise Program_Error;
   exception
      when Ada.Numerics.Argument_Error => null;
   end;

   begin
      Inverse_Result := Inverse_Root (0.0 * M_LF * M_LF);
      raise Program_Error;
   exception
      when Constraint_Error => null;
   end;
end Dimensions4;

--  Each precision must use its own elementary functions instance.
--  { dg-final { scan-tree-dump "ada.numerics.elementary_functions" "original" } }
--  { dg-final { scan-tree-dump "ada.numerics.long_elementary_functions" "original" } }
--  { dg-final { scan-tree-dump "ada.numerics.long_long_elementary_functions" "original" } }
