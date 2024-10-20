<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" 
"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>

<head>
<title>Free Template 05</title>
<meta name="description" content="add your site description here" />
<meta name="keywords" content="add your search engine keywords here separated by commas" />
<meta name="designer" content="My Arts Desire/Round the Bend Wizards" />
<meta http-equiv="Content-Language" content="en-us" />
<meta http-equiv="imagetoolbar" content="false" />
<link rel="stylesheet" type="text/css" href="style.css" />
</head>

<body>

<div class="wrapper" style="width: 753px; height: 1217px">
<table>
<tbody>
<tr>
<td colspan="2" class="sitename">
<b><font face="Georgia" size="6" color="#000080">&nbsp;DASP<br>
Distributive Analysis Stata Package</font></b> </td>
</tr>
<tr>
<td>&nbsp;</td>
<td><img src="../images/shadowright.jpg" width="650" height="15" alt="shadow" /><p align="center">

<a href="../index.html">Home</a> &bull; 
<a href="../aboutdasp.htm">About <i>DASP</i></a> &bull; 
<a href="../manuals.htm">Manuals</a> &bull; 
<a href="../modules.htm">Modules</a> &bull; 
<a href="../examples/examples.htm">Examples</a> &bull;&nbsp; 
<a href="../faqs.htm">FAQs</a> &bull; 
<a href="../contact.htm">Contact</a>
</td>
</tr>
<tr>
<td class="sidebar" width="727" colspan="2" style="width: 600px">







<p>&nbsp;</div>
 <%
    String nom="";
    String userid="";
    %>
<% 
    try{
    userid = (String)session.getAttribute("userid");
    System.out.println("araar "+userid);
    nom = (String)session.getAttribute("username");
   }
   catch(Exception e)
   {}
%>


<table height="1" cellspacing="0" cellpadding="0" width="600" border="0" style="border-collapse: collapse" bordercolor="#111111">
  <tr>
    <td width="408" height="1">
    <p align="left">
    <span style="FONT-FAMILY: Times New Roman; TEXT-DECORATION: underline; font-weight:700">
   
    <font color="#000080" size="4">You&#39;re welcome <%=  nom%> </font></span></p>
    </td>
    
    <%
    if (userid.compareTo("1000000")==0)
    {
    %> <td width="192" height="1"><a href="../ECNAdminTools.html"><img border="0" src="../images/admintools3.jpg" width="81" height="22" /></a></td>
    <%}
 

%>
    
  </tr>
</table>
 <blockquote>
   <p align="left"><u><font style="font-size: 14pt" face="Square721 BT">Services</font></u></p>
	<p align="left">
	<span style="font-weight: 700">
	<font size="2" face="Tahoma">Download DASP Package:&nbsp; </font>
	<font size="2" face="Tahoma">(Updated in: 03 December 2009)</font></span></p>
	<p align="left"><font face="Tahoma" color="#0000FF">
	<span style="font-weight: 700">
	<font color="#0000FF" size="3"><font color="#0000FF"><u>
	<a href="../modules/DASP_V2.1.zip"><u>Distributive Analysis Stata Package (V2.1)</u></a></u></font><u></a></u><a href="../modules/DASP_V1.4.zip"><u><font color="#0000FF">
</font> </u></a></font></span></font></p>
 </blockquote>
</a><span style="font-size: 9pt; font-family: Verdana"><CENTER><B>&nbsp;</B></CENTER>
</table>
<p><br>
&nbsp;

</body>

</html>