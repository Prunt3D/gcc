--  { dg-do run }

procedure Max_Entry_Queue_Length2 is
   protected Worker is
      entry Do_Work
      with Max_Entry_Queue_Length => -1;
      procedure Unblock;
   private
      X : Boolean := False;
   end Worker;

   protected body Worker is
      entry Do_Work when X is
      begin
         pragma Warnings (Off, "potentially blocking operation in protected operation");
         delay 0.2;
         pragma Warnings (On, "potentially blocking operation in protected operation");
      end Do_Work;

      procedure Unblock is
      begin
         X := True;
      end Unblock;
   end Worker;

   task type T is
      entry Finish;
   end T;

   task body T is
   begin
      Worker.Do_Work;
      accept Finish;
   end T;

   Tasks : array (1 .. 10) of T;
begin
   delay 1.0;
   Worker.Unblock;
   for I in Tasks'Range loop
      Tasks (I).Finish;
   end loop;
end Max_Entry_Queue_Length2;
