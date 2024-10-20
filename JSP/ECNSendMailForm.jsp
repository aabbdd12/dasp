
<%@ page import="javax.mail.internet.*, javax.mail.*" %> 
<html> <head>
<meta http-equiv="Content-Language" content="fr-ca">
<meta name="GENERATOR" content="Microsoft FrontPage 5.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<title>DAD</title>
<style>
<!--
td{font-family:arial,helvetica,sans-serif;}
         .txt {font-size: 12px; font-family: arial, helvetica;}
         .txtcoul {font-size: 12px; font-family: arial, helvetica; color: #000000;}
-->
</style>
</head>

<body leftmargin="15">
    

 <%
    String useridtmp="";

    if (request.getParameter("userid")!= null)
        {
        useridtmp = request.getParameter("userid");
        
        }
    else
        {
        useridtmp=(String)session.getAttribute("userid");
        
        }
    session.setAttribute("useridtmp",useridtmp);

%>
  <table cellspacing="0" cellpadding="0" width="600" border="0"  style="border-collapse: collapse" bordercolor="#111111">
             
        <tr>
        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
          <td class="black" style="background-color: #E4E9FF" width="50%" bgcolor="##006699" height="27" bordercolor="#E4E9FF">
          <div style="border-style: solid">
            <b><font color="#000000"><span style="background-color: #E4E9FF">
            &nbsp;</span></font></b></span><b><font color="#000000"><span style="font-family: Tahoma; background-color:#E4E9FF"><font size="2">Contact the whole group</font></span></font></b><span style="font-family: Times New Roman"></div>
          </td>
          </span>
        </tr>
      
        
        </table>
 <table cellspacing="0" cellpadding="0" width="600" border="0"  style="border-collapse: collapse" bordercolor="#111111">
  
	   
                <form  method="post" action="/DAD/servlet/Mimap.ECNSendMailForm">


                            <tr>
                <td valign="center" align="right" width="250" height="16" style="font-family: arial, helvetica, sans-serif">
                <font size="2" face="Tahoma">&#160;</font></td>
                <td height="16" style="font-family: arial, helvetica, sans-serif" width="391">
                <font size="2" face="Tahoma">&#160;</font></td>
              </tr>
              
              
                            <tr>
        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
                <td align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="250" bgcolor="#D5D5FF">
                <font size="2"><b><span style="font-family: Tahoma">Author:</span></b></font></td>
                <td height="22" style="font-family: arial, helvetica, sans-serif" width="391">
                <input maxlength="80" size="40" name="from" value="<%=(String)session.getAttribute("email")%>"></td>
                              </span>
                            </tr>
                           
              
                <tr>
                <td align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="250" bgcolor="#D5D5FF">
                <font size="2"><b><span style="font-family: Tahoma">Subject:</span></b></font></td>
                <td height="22" style="font-family: arial, helvetica, sans-serif" width="391">
                        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
                <input maxlength="80" size="40"  name="subject" ></span></td>
              </tr>

                <tr>
                <td align="right" height="22" style="font-family: arial, helvetica, sans-serif" width="250" bgcolor="#D5D5FF">
                <font size="2"><b><span style="font-family: Tahoma">Message:</span></b></font></td>
                <td height="22" style="font-family: arial, helvetica, sans-serif" width="391">
                <span style="font-size: 12.0pt; font-family: Times New Roman">
                <textarea rows="4" name="body" cols="55"></textarea></span></td>
              </tr>
           </table>
  <p>&nbsp;</p>

	
            
            <tr>
              <span style="font-size: 12.0pt; font-family: Times New Roman">
                <p align="center"><span style="font-size: 12.0pt; font-family: Times New Roman"></td>
                <td align="right" height="1" style="font-family: arial, helvetica, sans-serif" width="367" bgcolor="#D5D5FF">
                <span style="font-size: 12.0pt; font-family: Times New Roman">
                <font size="2"><b><span style="font-family: Tahoma">Attachment:</span></b></font></span></td>
                <td height="1" style="font-family: arial, helvetica, sans-serif" width="352">
        
               
               <span style="font-size: 12.0pt; font-family: Times New Roman">
                <input type="file" size="19" name="file" /></td>
            </span>
            </span>
            </tr>
  </table>
<p align="center">&nbsp;</p>
  <table border="0" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="547" id="AutoNumber1">
    <tr>
      <td width="100%">
      <p align="center">
      <input type="submit" value="Send" name="B1" style="font-size: 10pt; font-weight: bold; background-color: #9999FF">&nbsp;
      <input type="reset" value="Reset" name="B2" style="font-size: 10pt; font-weight: bold; color: #000000; background-color: #9999FF"></td>
    </tr>
  </table>
   </form>
  <!--p align="center">&nbsp;</p-->

  </b>
</body>
<% //String to = request.getParameter("to");
    Address[] toAddresses = (Address[])session.getAttribute("to"); //= InternetAddress.parse(to);
    %>

<b>
  <p>&nbsp;Sending mail to :</p>
  <% for (int i =0; i< toAddresses.length ; i++)
{%><p>
   &nbsp;<%=toAddresses[i].toString()%>
<%}%></p>
</html>