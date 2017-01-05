<%@ Page Language="vb" AutoEventWireup="false" Codebehind="WebForm1.aspx.vb" Inherits="Walkthrough_WebAppl_VB.WebForm1"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
	<HEAD>
		<title>WebForm1</title>
		<meta name="GENERATOR" content="Microsoft Visual Studio .NET 7.1">
		<meta name="CODE_LANGUAGE" content="Visual Basic .NET 7.1">
		<meta name="vs_defaultClientScript" content="JavaScript">
		<meta name="vs_targetSchema" content="http://schemas.microsoft.com/intellisense/ie5">
	</HEAD>
	<body MS_POSITIONING="GridLayout" bgColor="#ffff66">
		<FORM id="Form1" method="post" runat="server">
			<asp:TextBox id="TextBox_HostName" style="Z-INDEX: 102; LEFT: 176px; POSITION: absolute; TOP: 40px"
				runat="server" Width="156" Height="24">localhost</asp:TextBox>
			<asp:Label id="Label1" style="Z-INDEX: 114; LEFT: 40px; POSITION: absolute; TOP: 40px" runat="server">Host Name:</asp:Label>
			<asp:Label id="Label2" style="Z-INDEX: 103; LEFT: 40px; POSITION: absolute; TOP: 80px" runat="server">Account</asp:Label>
			<asp:TextBox id="TextBox_Account" style="Z-INDEX: 104; LEFT: 176px; POSITION: absolute; TOP: 80px"
				runat="server" Width="156" Height="24">demo</asp:TextBox>
			<asp:Label id="Label3" style="Z-INDEX: 105; LEFT: 40px; POSITION: absolute; TOP: 120px" runat="server">User ID</asp:Label>
			<asp:TextBox id="TextBox_UserID" style="Z-INDEX: 106; LEFT: 176px; POSITION: absolute; TOP: 120px"
				runat="server" Width="156" Height="24">rajank</asp:TextBox>
			<asp:Label id="Label4" style="Z-INDEX: 107; LEFT: 40px; POSITION: absolute; TOP: 160px" runat="server">Password:</asp:Label>
			<asp:TextBox id="TextBox_Password" style="Z-INDEX: 108; LEFT: 176px; POSITION: absolute; TOP: 160px"
				runat="server" Width="156" Height="24" TextMode="Password">ani2ka</asp:TextBox>
			<asp:Label id="Label5" style="Z-INDEX: 109; LEFT: 40px; POSITION: absolute; TOP: 200px" runat="server">File Name:</asp:Label>
			<asp:TextBox id="TextBox_FileName" style="Z-INDEX: 110; LEFT: 176px; POSITION: absolute; TOP: 200px"
				runat="server" Width="156" Height="24">CUSTOMER</asp:TextBox>
			<asp:RadioButtonList id="RadioButtonList1" style="Z-INDEX: 111; LEFT: 376px; POSITION: absolute; TOP: 40px"
				runat="server">
				<asp:ListItem Value="UniData" Selected="True">UniData</asp:ListItem>
				<asp:ListItem Value="UniVerse">UniVerse</asp:ListItem>
			</asp:RadioButtonList>
			<asp:TextBox id="TextBox_data" style="Z-INDEX: 112; LEFT: 32px; POSITION: absolute; TOP: 272px"
				runat="server" Width="736px" Height="224px" TextMode="MultiLine"></asp:TextBox>
			<asp:Button id="Button_Load" style="Z-INDEX: 113; LEFT: 704px; POSITION: absolute; TOP: 240px"
				runat="server" Text="Load"></asp:Button></FORM>
	</body>
</HTML>
