--  { dg-do run }
--  { dg-options "-O2" }

procedure Float_Decompose is
   generic
      type T is digits <>;
   procedure Test;

   procedure Test is
      Small : constant T := T'Scaling (1.0, T'Machine_Emin - 1);
      Tiny  : constant T := T'Scaling (Small, 1 - T'Machine_Mantissa);

      procedure Check (Value : T; Exponent : Integer; Fraction : T) is
         X : T := Value with Volatile;
         F : constant T := T'Fraction (X);
         E : constant Integer := T'Exponent (X);
         C : constant T := T'Compose (X, Exponent);
      begin
         if E /= Exponent or else F /= Fraction or else C /= Value then
            raise Program_Error;
         end if;

         --  Equality alone cannot distinguish positive and negative zero.

         if T'Copy_Sign (1.0, F) /= T'Copy_Sign (1.0, Value)
           or else T'Copy_Sign (1.0, C) /= T'Copy_Sign (1.0, Value)
         then
            raise Program_Error;
         end if;
      end Check;

      procedure Check_Both_Signs
        (Value : T; Exponent : Integer; Fraction : T)
      is
      begin
         Check (Value, Exponent, Fraction);
         Check (-Value, Exponent, -Fraction);
      end Check_Both_Signs;

      procedure Check_Remainder (X, Y, Expected : T) is
         A : T := X with Volatile;
         B : T := Y with Volatile;
      begin
         if T'Remainder (A, B) /= Expected
           or else T'Remainder (-A, B) /= -Expected
           or else T'Remainder (A, -B) /= Expected
           or else T'Remainder (-A, -B) /= -Expected
         then
            raise Program_Error;
         end if;
      end Check_Remainder;

   begin
      Check_Both_Signs (0.0, 0, 0.0);
      Check_Remainder (0.5, 1.0, 0.5);
      Check_Remainder (1.5, 1.0, -0.5);
      Check_Remainder (5.0, 2.0, 1.0);
      Check_Remainder (7.0, 2.0, -1.0);

      --  Exercise every normal exponent, including the extrema, with both
      --  a power of two and a nonzero fractional significand.

      for E in T'Machine_Emin .. T'Machine_Emax loop
         Check_Both_Signs (T'Scaling (0.5, E), E, 0.5);
         Check_Both_Signs (T'Scaling (0.75, E), E, 0.75);
      end loop;

      Check_Both_Signs
        (T'Last, T'Machine_Emax,
         1.0 - T'Scaling (1.0, -T'Machine_Mantissa));

      if T'Denorm then
         Check_Remainder (3.0 * Tiny, 2.0 * Tiny, -Tiny);
         Check_Remainder (5.0 * Tiny, 2.0 * Tiny, Tiny);

         --  Every subnormal power of two must normalize in one step.

         for E in T'Machine_Emin - T'Machine_Mantissa + 1
                    .. T'Machine_Emin - 1
         loop
            Check_Both_Signs (T'Scaling (0.5, E), E, 0.5);
         end loop;

         Check_Both_Signs
           (3.0 * Tiny, T'Machine_Emin - T'Machine_Mantissa + 2, 0.75);
         Check_Both_Signs
           (Small - Tiny, T'Machine_Emin - 1,
            1.0 - T'Scaling (1.0, 1 - T'Machine_Mantissa));
      end if;
   end Test;

   procedure Test_Float is new Test (Float);
   procedure Test_Long_Float is new Test (Long_Float);
   procedure Test_Long_Long_Float is new Test (Long_Long_Float);
begin
   Test_Float;
   Test_Long_Float;
   Test_Long_Long_Float;
end Float_Decompose;
