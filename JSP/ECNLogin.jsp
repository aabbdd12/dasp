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


         <FORM METHOD=POST ACTION="ECNValidateUser.jsp">
         <table border="0" cellpadding="10" cellspacing="10" style="border-collapse: collapse" bordercolor="#111111" width="98%" id="AutoNumber1" height="97">
    <tr>
      <td width="36%" height="32">
      <p align="right">
      <font color="#000080" face="Verdana" style="font-size: 9pt"><b>User ID:</b></font></td>
      <td width="30%" height="32">
      <p align="center"><span style="font-size: 9pt"><font face="Verdana"><INPUT NAME="USERID" SIZE=19 MAXLENGTH=20 type=text ></font></span></td>
      <td width="104%" height="32">&nbsp;</td>
    </tr>
    <tr>
      <td width="36%" height="32">
      <p align="right">
      <FONT FACE="Verdana" COLOR=#000080 style="font-size: 9pt"><B>Password:</B></FONT></td>
      <td width="30%" height="32">
      <p align="center"><span style="font-size: 9pt"><font face="Verdana"><INPUT NAME="PASSWORD" SIZE=19 MAXLENGTH=20 type=password ></font></span></td>
      <td width="34%" height="32">&nbsp;</td>
    </tr>
    <tr>
      <td width="36%" height="33">&nbsp;</td>
      <td width="30%" height="33">&nbsp;</td>
      <td width="34%" height="33"><i>
      <font style="font-size: 9pt" face="Verdana">
      <a target="_self" href="ECNForgotPassword.jsp">Forgot your password ?</a></font></i></td>
    </tr>
  </table>
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="97%" id="AutoNumber2">
    <tr>
      <td width="36%">&nbsp;</td>
      <td width="13%">
      <span style="font-size: 9pt"><font face="Verdana">
      <INPUT NAME="SUB" TYPE="submit" VALUE="LOGIN" style="font-size: 8pt; font-weight: bold; float: right; background-color: #9999FF"></font></span></td>
      <td width="2%">&nbsp;</td>
      <td width="16%">
      <span style="font-size: 9pt"><font face="Verdana">
      <INPUT NAME="SUB1" TYPE="submit" VALUE="CLEAR" style="float: left; font-size: 8pt; font-weight: bold; background-color: #9999FF"></font></span></td>
      <td width="40%">&nbsp;</td>
    </tr>
  </table>
  <p> 
<CENTER>
 </p>
 <div align="left">
<TABLE COLS="3" BORDER="0"  RULES=none width="600" bordercolor="#111111" cellpadding="0" cellspacing="0" style="border-collapse: collapse">
    <tr>
  				<% String  message= "" ;
                
                message = (String)request.getParameter("message");
                try
                {
                if (message.compareTo("OK")==0)
                {
                %><font face="Verdana"><span style="font-size: 9pt"> </span>
                </font>

                <td width="465" align="center" bgcolor="#008000"><b>
                <font face="Verdana">
                <font color="#FFFFFF" style="font-size: 9pt">Success : 
                User Created </font><font style="font-size: 9pt"><br>
                </td>
                <%}
                 

                else if (message != null)
                {
                %><font face="Verdana"><span style="font-size: 9pt"> </span>
                </font> </font></font></b>
                <td width="465" align="center" bgcolor="#FF0000" height="10"><b>
                <font face="Verdana">
                <font color="#FFFFFF" style="font-size: 9pt">Error : Wrong 
                User or Password !!!</font><font style="font-size: 9pt"><br>
                </td>
                <%}
                }
                catch(Exception e)
                {}
                 %><font face="Verdana"><span style="font-size: 9pt"> </span>
                </font> </font></font></b>
	</TR>

  <td width="365">
  <td width="375" align="right">
&nbsp;</TABLE>
 </div>
 </FORM>






<p>&nbsp;</div>

</table>
<p><br>
&nbsp;

</body>

</html>