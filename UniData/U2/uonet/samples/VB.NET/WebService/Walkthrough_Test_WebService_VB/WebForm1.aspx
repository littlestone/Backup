<%@ Page Language="vb" AutoEventWireup="false" Codebehind="WebForm1.aspx.vb" Inherits="Walkthrough_Test_WebService_VB.WebForm1"%>
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
			<asp:TextBox id="TextBox_HostName" style="Z-INDEX: 102; LEFT: 232px; POSITION: absolute; TOP: 64px"
				runat="server">localhost</asp:TextBox>
			<asp:Label id="Label1" style="Z-INDEX: 114; LEFT: 72px; POSITION: absolute; TOP: 72px" runat="server">Host Name:</asp:Label>
			<asp:Label id="Label2" style="Z-INDEX: 103; LEFT: 64px; POSITION: absolute; TOP: 104px" runat="server">Account:</asp:Label>
			<asp:TextBox id="TextBox_Account" style="Z-INDEX: 104; LEFT: 232px; POSITION: absolute; TOP: 104px"
				runat="server">demo</asp:TextBox>
			<asp:Label id="Label3" style="Z-INDEX: 105; LEFT: 64px; POSITION: absolute; TOP: 144px" runat="server">User ID:</asp:Label>
			<asp:TextBox id="TextBox_UserID" style="Z-INDEX: 106; LEFT: 232px; POSITION: absolute; TOP: 144px"
				runat="server">rajank</asp:TextBox>
			<asp:Label id="Label4" style="Z-INDEX: 107; LEFT: 64px; POSITION: absolute; TOP: 184px" runat="server">Password:</asp:Label>
			<asp:TextBox id="TextBox_Password" style="Z-INDEX: 108; LEFT: 232px; POSITION: absolute; TOP: 184px"
				runat="server" TextMode="Password">ani2ka</asp:TextBox>
			<asp:Label id="Label5" style="Z-INDEX: 109; LEFT: 64px; POSITION: absolute; TOP: 224px" runat="server">File Name:</asp:Label>
			<asp:TextBox id="TextBox_FileName" style="Z-INDEX: 110; LEFT: 232px; POSITION: absolute; TOP: 224px"
				runat="server">CUSTOMER</asp:TextBox>
			<asp:RadioButtonList id="RadioButtonList1" style="Z-INDEX: 111; LEFT: 448px; POSITION: absolute; TOP: 64px"
				runat="server">
				<asp:ListItem Value="UniData" Selected="True">UniData</asp:ListItem>
				<asp:ListItem Value="UniVerse">UniVerse</asp:ListItem>
			</asp:RadioButtonList>
			<asp:TextBox id="TextBox_data" style="Z-INDEX: 112; LEFT: 56px; POSITION: absolute; TOP: 328px"
				runat="server" TextMode="MultiLine" Width="728px" Height="184px"></asp:TextBox>
			<asp:Button id="Button_Load" style="Z-INDEX: 113; LEFT: 720px; POSITION: absolute; TOP: 296px"
				runat="server" Text="Load"></asp:Button></FORM>
	</body>
</HTML>
