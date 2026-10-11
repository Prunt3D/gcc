-- { dg-do run }
-- { dg-options "-gnat2022" }

--  Exercise task types, private protected types, homographic null procedures,
--  access parameters and explicit overrides, including argument side effects.

procedure Inherited_Null2 is
   Evaluations : Natural := 0;
   Overrides   : Natural := 0;

   function Next_Value return Natural is
   begin
      Evaluations := Evaluations + 1;
      return Evaluations;
   end Next_Value;

   package Types is
      type Parent is synchronized interface;
      procedure Action (This : in out Parent; Value : Natural) is null;
      procedure Action (This : access Parent) is null;
      procedure Pair (Left, Right : in out Parent) is null;

      type Other is synchronized interface;
      procedure Action (This : in out Other; Value : Natural) is null;

      task type Worker is new Parent and Other with
      end Worker;

      type Instance is synchronized new Parent and Other with private;

      protected type Overridden is new Parent with
         overriding procedure Action (Value : Natural);
      end Overridden;

   private
      protected type Instance is new Parent and Other with
      end Instance;
   end Types;

   package body Types is
      task body Worker is
      begin
         null;
      end Worker;

      protected body Instance is
      end Instance;

      protected body Overridden is
         procedure Action (Value : Natural) is
         begin
            Overrides := Overrides + 1;
         end Action;
      end Overridden;
   end Types;

   procedure Dispatch (Object : in out Types.Parent'Class) is
   begin
      Types.Action (Object, Next_Value);
   end Dispatch;

   procedure Dispatch (Object : in out Types.Other'Class) is
   begin
      Types.Action (Object, Next_Value);
   end Dispatch;

   procedure Dispatch (Object : access Types.Parent'Class) is
   begin
      Types.Action (Object);
   end Dispatch;

   procedure Dispatch_Pair (Object : in out Types.Parent'Class) is
   begin
      Types.Pair (Object, Object);
   end Dispatch_Pair;

   Task_Object      : aliased Types.Worker;
   Protected_Object : aliased Types.Instance;
   Override_Object  : aliased Types.Overridden;
begin
   Types.Action (Task_Object, Next_Value);
   Types.Action (Protected_Object, Next_Value);
   Types.Action (Override_Object, Next_Value);

   Dispatch (Types.Parent'Class (Task_Object));
   Dispatch (Types.Other'Class (Task_Object));
   Dispatch (Types.Parent'Class (Protected_Object));
   Dispatch (Types.Other'Class (Protected_Object));
   Dispatch (Types.Parent'Class (Override_Object));

   Types.Action (Task_Object'Access);
   Types.Action (Protected_Object'Access);
   Types.Action (Override_Object'Access);
   Dispatch (Task_Object'Access);
   Dispatch (Protected_Object'Access);
   Dispatch (Override_Object'Access);

   Types.Pair (Task_Object, Task_Object);
   Types.Pair (Protected_Object, Protected_Object);
   Dispatch_Pair (Task_Object);
   Dispatch_Pair (Protected_Object);

   if Evaluations /= 8 or else Overrides /= 2 then
      raise Program_Error;
   end if;
end Inherited_Null2;
