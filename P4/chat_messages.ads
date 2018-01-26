--Miguel Ángel Alba Blanco
with Ada.Strings.Unbounded;

package Chat_Messages is
	package ASU renames Ada.Strings.Unbounded;
	type Message_Type is (Init,Reject,Confirm,writer,Logout);
end Chat_Messages;