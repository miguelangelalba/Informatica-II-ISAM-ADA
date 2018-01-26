with Ada.Strings.Unbounded;

package Chat_Messages is
	 package ASU renames Ada.Strings.Unbounded;
	 type Message_Type is (Init,Writer,Server);
end Chat_Messages;