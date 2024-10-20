
<%@ page import="java.sql.* ,java.util.*, Mimap.DADUser " %>
<jsp:useBean id="query2" class="Mimap.DADUser" />
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!-- saved from url=(0044)http://www.mimap.ecn.ulaval.ca/download.html -->
<HTML><HEAD><TITLE>Tout est beau</TITLE>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
<META content="Abdelkrim Araar" name=Author>
<META content="MSHTML 6.00.2800.1106" name=GENERATOR></HEAD>
<BODY text=#000099 vLink=#551a8b aLink=#990000 link=#cc0000 bgColor=#ffffff>

 <%
    String nom="";
    String userid="";
    %>
<% 
    try{
    userid = (String)session.getAttribute("userid");
   nom = (String)session.getAttribute("username");
   }
   catch(Exception e)
   {}
%>


<table height="1" cellspacing="0" cellpadding="0" width="600" border="0" style="border-collapse: collapse" bordercolor="#111111">
  <tr>
    <td width="66%" height="1">
    <p align="left">
    <span style="FONT-FAMILY: Times New Roman; TEXT-DECORATION: underline; font-weight:700">
   
    <font color="#000080" size="4">You&#39;re welcome <%=  nom%> </font></span></p>
    </td>
    
    <% if (userid.compareTo("1000000")==0){
        %> <td width="17%" height="1"><a href="../ECNAdminTools.html"><img border="0" src="../images/admintools3.jpg" width="81" height="22" /></a></td>
    <%}else {%>
    <td width="17%" height="1"><a href="ECNCalendar.jsp"><b>
    <script language="javascript">
    <!--
    today = new Date()
    document.write("", today.getDate(),"/",today.getMonth()+1,"/",today.getYear())
    //-->
    </script>
    </a>
    </b>
</td>
<%}%>
    
  </tr>
</table>
<CENTER><IMG height=21 src="download_files/line6.gif" width=623></CENTER>
<P>&nbsp;
<P align=center><IMG height=43 src="download_files/oe_d011.gif" width=40 
border=0><IMG height=43 src="download_files/oe_a011.gif" width=32><IMG height=43 
src="download_files/oe_d011.gif" width=40> 
<DIV align=center>
<CENTER>
<TABLE width="57%" border=1>
  <TBODY>
  <TR>
    <TD width="100%" bgColor=#ffffcc>
      <P align=center><B><I><BLINK>DOWNLOAD NOW</BLINK></I></B><A 
      href="http://www.mimap.ecn.ulaval.ca/DADV42/softwares/Install_DAD42_October_2002.exe"> 
      </A><BR><B><I><FONT face=Tahoma color=#0000ff size=5>DAD 
      4.2<BLINK>&nbsp;</BLINK></FONT></I></B></P>
      <P align=center><B>19</B><FONT size=3><B> Mo&nbsp;</B> 
      <B>(19&nbsp;648&nbsp;391 octets)</B></FONT></P>
      <TABLE id=AutoNumber1 style="BORDER-COLLAPSE: collapse" 
      borderColor=#111111 cellSpacing=0 cellPadding=0 width="100%" border=1>
        <TBODY>
        <TR>
          <TD width="33%">&nbsp;</TD>
          <TD align=middle width="33%"><B>&nbsp;Server 1</B></TD>
          <TD align=middle width="34%"><B>&nbsp;Server 2</B></TD></TR>
        <TR>
          <TD width="33%">&nbsp;<B> Zipped format</B></TD>
          <TD align=middle width="33%"><A 
            href="http://www.mimap.ecn.ulaval.ca/DADV42/softwares/DAD42.zip">DAD42.zip</A></TD>
          <TD align=middle width="34%"><A 
            href="http://132.203.59.111/DAD/DAD42.zip">DAD42.zip</A></TD></TR>
        <TR>
          <TD width="33%"><B>&nbsp;*.exe&nbsp; format </B></TD>
          <TD align=middle width="33%"><A 
            href="http://www.mimap.ecn.ulaval.ca/DADV42/softwares/DAD42.exe">DAD42.exe</A></TD>
          <TD align=middle width="34%"><A 
            href="http://132.203.59.111/DAD/DAD42.exe">DAD42.exe</A></TD></TR></TBODY></TABLE>
      <P align=center><FONT color=#000000 size=3><B><I><SPAN 
      style="BACKGROUND-COLOR: #ffffff">Updated in: 
      14-01-2003</SPAN></I></B></FONT></P></TD></TR>
  <TR>
    <TD width="100%" bgColor=#f3dc8d>
      <P align=center><B><I><A 
      href="http://www.mimap.ecn.ulaval.ca/dad4.0/jinstall4-1_2002-02.exe">DOWNLOAD 
      NOW</A></I></B> <BR><B><I><BLINK><FONT face=Tahoma color=#0000ff 
      size=5>DAD 4.1&nbsp;</FONT></BLINK></I></B></P>
      <P align=center><B>12</B><B> Mo (12 214 336)</B></P>
      <P align=center><FONT color=#000000 size=3><B><I>Updated in: 
      06-03-2002</I></B></FONT></P></TD></TR>
  <TR>
    <TD width="100%" bgColor=#ffcc33>
      <P align=center><B><I><A 
      href="http://www.mimap.ecn.ulaval.ca/install/jinstall.exe">DOWNLOAD 
      NOW</A></I></B> <BR><B><I><BLINK><FONT face=Tahoma color=#0000ff 
      size=5>DAD 3.1&nbsp;</FONT></BLINK></I></B></P>
      <P align=center><B>5</B><B>,6 Mo (5 570 518)</B></P>
      <P align=center><FONT color=#000000 size=3><B><I>Updated in: 
      03-08-2001</I></B></FONT></P></TD></TR></TBODY></TABLE></CENTER></DIV>
<CENTER><B>&nbsp;</B></CENTER></BODY></HTML>
