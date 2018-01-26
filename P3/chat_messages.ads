with Ada.Strings.Unbounded;

package Chat_Messages is
	package ASU renames Ada.Strings.Unbounded;
	type Message_Type is (Init,Welcome,Writer,Server,Logout);
end Chat_Messages;