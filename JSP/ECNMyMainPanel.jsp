<%@ page import="java.sql.* ,java.util.*, Mimap.ECNUser, Mimap.ECNProject " %>
<jsp:useBean id="query2" class="Mimap.ECNUser" />
<jsp:useBean id="project" class="Mimap.ECNProject" />
<jsp:useBean id="memo" class="Mimap.ECNMemos" />
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252" />
<meta name="GENERATOR" content="Microsoft FrontPage 5.0" />
<meta name="ProgId" content="FrontPage.Editor.Document" />
<title>PEP-NET.org</title>
</head>

<body>
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
<td valign="top" width="579" height="1">
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
<% int count =0;
	int count1=0;
        int count11=0;
	int count2=0;
	%>
<!--                Liste des Projets                --><% ResultSet rs2; 
  String projid;
  String projname;
  String projdesc;
  String projtitle;
  String projperiod;
  String projdate;
  String projtheme;
             
  rs2 = query2.getUserProject( userid,"GENERAL"); 
                        
  while (rs2.next())
  {

   if (count==0)
   {
   %>
<table style="BORDER-COLLAPSE: collapse" bordercolor="#111111" height="47" cellspacing="0" cellpadding="0" width="585" border="0">
  <tr>
    <td width="31" height="43">&nbsp;</td>
    <td valign="top" width="585" colspan="5" height="38"><font color="#000080">
    <span style="font-size: 14pt"><b><span style="font-family: Times New Roman">&nbsp;</span></b></span></font></td>
  </tr>
  <tr>
    <td width="31" height="43" rowspan="100">
    <img height="2" src="../images/cale10.gif" width="10" border="0" /></td>
    <td valign="top" width="484" colspan="5" height="38">
    <p class="txt1"><b><span style="FONT-FAMILY: Tahoma">
    <font color="#0000ff" size="2">My Projec</font></span></b><img height="2" src="../images/2line.gif" width="377" align="left" border="0" /><b><span style="FONT-FAMILY: Tahoma"><font color="#0000ff" size="2">ts</font></span><font color="#000080"><span style="FONT-SIZE: 14pt; FONT-FAMILY: Times New Roman">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </span></font></b></p>
    </td>
  </tr>
  <%
   }
      count ++;

      projid = rs2.getString("PROJID");
      projname = rs2.getString("NAME");
      projdesc = rs2.getString("DESCRIPTION");
      projtitle = rs2.getString("TITLE");
      projdate = rs2.getString("STARTINGDATE");
      projperiod = rs2.getString("PERIOD");
      ResultSet rs3; 
      
      rs3 = project.getUserRoleInProject(userid,projid);
                    
      String isadmin =null;//= rs2.getString("ISADMIN");
      String tmp=null;
      while(rs3.next())
           {
           tmp = rs3.getString("ISADMIN");
           try
           {
           tmp = tmp.toUpperCase();
           }
           catch(Exception e){}
           
           
           if (tmp.compareTo("ADMIN")==0)
           {
           isadmin="ADMIN";
           rs3.afterLast();
           }
           else if (tmp.compareTo("LEADER")==0 || tmp.compareTo("SUPERVISOR")==0 )
           {
           isadmin=tmp;
           }
           else
           isadmin="0";                
           }
                       
       		%>
  <tr>
    <td width="19" height="21">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
    <a href="ECNMyGeneralProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
    <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
    <td width="90" height="1">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
    <a href="ECNMyGeneralProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
    <%= projname %> </a></span></td>
    <td width="200" height="1">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
    </span></td>
    <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
    <td width="62" height="21">
    <p align="center">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><font size="2"><%=nb%> 
    doc(s)</font></span></p>
    </td>
    <td width="73" height="1"><% 
                           
     if (isadmin.compareTo("1---")==0 || isadmin.compareTo("ADMIN---")==0){%>
    <p align="left">
    <a href="ECNMyGeneralProjectAdmin.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>">
    <img height="21" src="../images/ProjectManager.gif" width="23" border="0" /></a></p>
    <%
                 }
                 %> </td>
  </tr>
  <%   
           } // end while
           
           rs2.beforeFirst();
           
           
     %> <%if (count >0) 
     {%>
</table>
<%}%>









<!--                Liste des Projets de Recherche                 --><%
        int mpiacount=0;
        int pmmacount=0;
        int cbmscount=0;
        int othecount=0;
        rs2 = query2.getUserProject( userid ,"RESEARCH","PEP"); 
        while (rs2.next())
        {
                        
         if (count1==0)
         {
         %>
<table style="BORDER-COLLAPSE: collapse" bordercolor="#111111" height="12" cellspacing="0" cellpadding="0" width="590" border="0">
  <tr>
    <td width="31" height="43">&nbsp;</td>
    <td valign="top" width="590" colspan="5" height="38"><font color="#000080">
    <span style="font-size: 14pt"><b><span style="font-family: Times New Roman">&nbsp;</span></b></span></font></td>
  </tr>
  <tr>
    <td width="31" height="8" rowspan="62">
    <img height="2" src="../images/cale10.gif" width="10" border="0" /></td>
    <td valign="top" width="489" colspan="5" height="38">
    <p class="txt1"><b><span style="FONT-FAMILY: Tahoma">
    <font color="#0000ff" size="2">My PEP Research Projec</font></span></b><img height="2" src="../images/2line.gif" width="377" align="left" border="0" /><b><span style="FONT-FAMILY: Tahoma"><font color="#0000ff" size="2">ts</font></span><font color="#000080"><span style="FONT-SIZE: 14pt; FONT-FAMILY: Times New Roman">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </span></font></b></p>
    </td>
   
  </tr>

  <%
           }
           count1++;
           projid = rs2.getString("PROJID");
           projname = rs2.getString("NAME");
           projdesc = rs2.getString("DESCRIPTION");
           projtitle = rs2.getString("TITLE");
           projdate = rs2.getString("STARTINGDATE");
           projperiod = rs2.getString("PERIOD");
           projtheme = rs2.getString("THEME");
           
           ResultSet rs3; 
           rs3 = project.getUserRoleInProject(userid,projid);
                    
           String isadmin =null;//= rs2.getString("ISADMIN");
           String tmp=null;
           while(rs3.next())
               {
               tmp = rs3.getString("ISADMIN");
               try
                {
                  tmp = tmp.toUpperCase();
                }
                catch(Exception e){}
                
                
                if (tmp.compareTo("ADMIN")==0)
                      {
                      isadmin="ADMIN";
                      rs3.afterLast();
                      }
                else if (tmp.compareTo("LEADER")==0 || tmp.compareTo("SUPERVISOR")==0 )
                      {
                      isadmin=tmp;
                      }
                else
                	  
                      isadmin="0";     
                 }  // end while rs3
            if (projtheme.compareTo("PMMA")==0)
                {
                if (pmmacount==0)
                    {
                    %>
                     
                 <tr> 
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">PMMA</font></span></b>
                </font></p>
                </td>
                
              
                 </tr>
                <% pmmacount++;}%>
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1">
                           
                 </td>
                </tr>
                <%} // end CBMS
                if (projtheme.compareTo("MPIA")==0)
                {
                if (mpiacount==0)
                    {
                    %>      
                 <tr>
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">MPIA</font></span></b>
                </font></p>
                </td>
       
                 </tr>
                <% mpiacount++;}%>
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"></td>
                </tr>
                <%} // end CBMS
                if (projtheme.compareTo("CBMS")==0)
                {
                if (cbmscount==0)
                    {
                    %>       
                 <tr>
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">CBMS</font></span></b>
                </font></p>
                </td>
               

                 </tr>
                <% cbmscount++;}%>
                
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"> </td>
                </tr>
                <%} // end CBMS
                
                 if (projtheme.compareTo("OTHER")==0)
                {
                if (othecount==0)
                    {
                    %>       
                 <tr>
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">OTHERS</font></span></b>
                </font></p>
                </td>
               

                 </tr>
                <% othecount++;}%>
                
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"> </td>
                </tr>
                <%} // end CBMS
                
                %>


  <tr>
    <td width="440" height="1" colspan="5">
    <hr color="#FFFFFF" size="1" width="377" align="left"></td>
  </tr>
  <%
     } // end while
   rs2.beforeFirst();
   
   
   if (count1>0){%>
</table>
<%}%>



<!--                Liste des Projets de Recherche                  --><%
        
        mpiacount=0;
        pmmacount=0;
        cbmscount=0;
        int   othercount=0;
        rs2 = query2.getUserProject( userid ,"RESEARCH","NATIONAL"); 
        while (rs2.next())
        {
                        
         if (count11==0)
         {
         %>
<table style="BORDER-COLLAPSE: collapse" bordercolor="#111111" height="12" cellspacing="0" cellpadding="0" width="590" border="0">
  <tr>
    <td width="31" height="43">&nbsp;</td>
    <td valign="top" width="590" colspan="5" height="38"><font color="#000080">
    <span style="font-size: 14pt"><b><span style="font-family: Times New Roman">&nbsp;</span></b></span></font></td>
  </tr>
  <tr>
    <td width="31" height="8" rowspan="62">
    <img height="2" src="../images/cale10.gif" width="10" border="0" /></td>
    <td valign="top" width="489" colspan="5" height="38">
    <p class="txt1"><b><span style="FONT-FAMILY: Tahoma">
    <font color="#0000ff" size="2">My National Research Projec</font></span></b><img height="2" src="../images/2line.gif" width="377" align="left" border="0" /><b><span style="FONT-FAMILY: Tahoma"><font color="#0000ff" size="2">ts</font></span><font color="#000080"><span style="FONT-SIZE: 14pt; FONT-FAMILY: Times New Roman">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </span></font></b></p>
    </td>
   
  </tr>

  <%
           }
           count11++;
           projid = rs2.getString("PROJID");
           projname = rs2.getString("NAME");
           projdesc = rs2.getString("DESCRIPTION");
           projtitle = rs2.getString("TITLE");
           projdate = rs2.getString("STARTINGDATE");
           projperiod = rs2.getString("PERIOD");
           projtheme = rs2.getString("THEME");
           
           ResultSet rs3; 
           rs3 = project.getUserRoleInProject(userid,projid);
                    
           String isadmin =null;//= rs2.getString("ISADMIN");
           String tmp=null;
           while(rs3.next())
               {
               tmp = rs3.getString("ISADMIN");
               try
                {
                  tmp = tmp.toUpperCase();
                }
                catch(Exception e){}
                
                
                if (tmp.compareTo("ADMIN")==0)
                      {
                      isadmin="ADMIN";
                      rs3.afterLast();
                      }
                else if (tmp.compareTo("LEADER")==0 || tmp.compareTo("SUPERVISOR")==0 )
                      {
                      isadmin=tmp;
                      }
                else
                	  
                      isadmin="0";     
                 }  // end while rs3
            if (projtheme.compareTo("PMMA")==0)
                {
                if (pmmacount==0)
                    {
                    %>
                     
                 <tr> 
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">PMMA</font></span></b>
                </font></p>
                </td>
                
              
                 </tr>
                <% cbmscount++;}%>
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"> </td>
                </tr>
                <%} // end CBMS
                if (projtheme.compareTo("MPIA")==0)
                {
                if (mpiacount==0)
                    {
                    %>      
                 <tr>
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">MPIA</font></span></b>
                </font></p>
                </td>
       
                 </tr>
                <% mpiacount++;}%>
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"> </td>
                </tr>
                <%} // end CBMS
                if (projtheme.compareTo("CBMS")==0)
                {
                if (cbmscount==0)
                    {
                    %>       
                 <tr>
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">PMMA</font></span></b>
                </font></p>
                </td>
               

                 </tr>
                <% cbmscount++;}%>
                
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"></td>
                </tr>
                <%} // end CBMS
                
                if (projtheme.compareTo("OTHER")==0)
                {
                if (othecount==0)
                    {
                    %>       
                 <tr>
                <td valign="top" width="30" colspan="5" height="38">
                <p class="txt1"><b><span style="FONT-FAMILY: Tahoma; TEXT-DECORATION: underline;">
                <font color="#0000FF" size="2">OTHERS</font></span></b>
                </font></p>
                </td>
               

                 </tr>
                <% othecount++;}%>
                
                <tr>
                <td width="19" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <img src="../images/projsmal.gif" border="0" width="14" height="14" /></a></span></td>
   
                <td width="90" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                <a href="ECNMyResearchProject.jsp?role=<%=isadmin%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projtitle=<%= projtitle%>&projdate=<%= projdate%>&projperiod=<%= projperiod%>">
                <%= projname %> </a></span></td>
    
                <td width="180" height="11">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projtitle %>
                </span></td>
   
                <% int nb = query2.CountDocumentsfromUserProject("PROJID",projid);%>
                <td width="51" height="11">
                <p align="center"><font size="2">
                <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%=nb%> doc(s)</span></font></p>
                </td>
                <td width="80" height="1"> </td>
                </tr>
                <%} // end CBMS
                %>


  <tr>
    <td width="440" height="1" colspan="5">
    <hr color="#FFFFFF" size="1" width="377" align="left"></td>
  </tr>
  <%
     } // end while
   rs2.beforeFirst();
   
   
   if (count11>0){%>
</table>
<%}%>
<!--                Liste des Proposals               --><%
                        rs2 = query2.getUserProposal(userid); 
                        
                        while (rs2.next())
                        {
                        
                        if (count2==0)
                        {
                        %>
<table style="BORDER-COLLAPSE: collapse" bordercolor="#111111" height="45" cellspacing="0" cellpadding="0" width="590" border="0">
  <tr>
    <td width="31" height="43">&nbsp;</td>
    <td valign="top" width="590" colspan="5" height="38"><font color="#000080">
    <span style="font-size: 14pt"><b><span style="font-family: Times New Roman">&nbsp;</span></b></span></font></td>
  </tr>
  <tr>
    <td width="31" height="43" rowspan="99">
    <img height="2" src="../images/cale10.gif" width="10" border="0" /></td>
    <td valign="top" width="489" colspan="3" height="38">
    <p class="txt1"><b><span style="FONT-FAMILY: Tahoma">
    <font color="#0000ff" size="2">My Proposals</font></span></b><img height="2" src="../images/2line.gif" width="377" align="left" border="0" /><b><span style="FONT-FAMILY: Tahoma"><font color="#0000ff" size="2"></font></span><font color="#000080"><span style="FONT-SIZE: 14pt; FONT-FAMILY: Times New Roman">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </span></font></b></p>
    </td>
  </tr>
  <%
                        }
                        count2++;
                        projid = rs2.getString("PROPID");
                        
                        projname = rs2.getString("NAME");
                        projdesc = rs2.getString("DESCRIPTION");
                        String projcode = rs2.getString("CODE");
                        String role1 = rs2.getString("ROLE");
                        String archive = rs2.getString("ARCHIVE");
                        
                        //ResultSet rs3; 
                        //rs3 = project.getUserRoleInProject((String)session.getAttribute("userid"),projid);
                        if (archive!=null  && (role1.compareTo("ADMIN")==0 || role1.compareTo("SUPERVISOR")==0 || role1.compareTo("RESSOURCE")==0))
                        {}
                        else
                        {
                              %>

                    <tr>
                    <td width="20" height="22">
                    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                    <a href="ECNMyProposal.jsp?role=<%=role1%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projcode=<%= projcode%>">
                    <img height="16" src="../images/doc.gif" width="13" border="0" /></a></span></td>
                    <td width="97" height="22">
                    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
                    <a href="ECNMyProposal.jsp?role=<%=role1%>&projid=<%= projid%>&projname=<%= projname %>&projdesc=<%= projdesc%>&projcode=<%= projcode%>">Pro-Pep-<%= projcode %> </a></span></td>
                    <td width="334" height="22">
                    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><%= projname %>
                    </span></td>
                    <td width="1" height="22"></td>
                    </tr>
                 <%
           }
     } // end while
   rs2.beforeFirst();
   
   
   if (count2>0){%>
<tr>
    <td width="20" height="22">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
    </span></td>
    <td width="97" height="22">
    </td>
    <td width="1" height="22"></td>
   </tr>
 <tr>
    <td width="20" height="22">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">
    </span></td>
    <td width="97" height="22">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman">Archived Proposals </a></span></td>
    <td width="334" height="22">
    <span style="FONT-SIZE: 10pt; FONT-FAMILY: Times New Roman"><a href="ECNListArchiveProposal.jsp?year=2003">2003</a>  <a href="ECNListArchiveProposal.jsp?year=2004">2004</a>  <a href="ECNListArchiveProposal.jsp?year=2005">2005</a>
    </span></td>
    <td width="1" height="22"></td>
   </tr>
</table>


<%}%>



<!--                Liste des Memos               -->

<%
rs2 = query2.getUserMemo( userid ); 
int count3 = 0;
while (rs2.next())
     {
                        
     if (count3==0)
     {
     %>
<table style="BORDER-COLLAPSE: collapse" bordercolor="#111111" height="45" cellspacing="0" cellpadding="0" width="651" border="0">
<form method="POST" action="ECNDeleteMemo.jsp?userid=<%=userid%>">  
 <tr>
    <td width="44" height="43">&nbsp;</td>
    <td valign="top" width="617" colspan="5" height="38"><font color="#000080">
    <span style="font-size: 14pt"><b><span style="font-family: Times New Roman">&nbsp;</span></td>
  </tr>
  <tr>
    <td width="44" height="43" rowspan="99">
    <img height="2" src="../images/cale10.gif" width="10" border="0" /></td>
    <td valign="top" width="431" colspan="6" height="38">
    <p class="txt1"><b><span style="FONT-FAMILY: Tahoma">
    <font color="#0000ff" size="2">My Memos</font></span></b><img height="2" src="../images/2line.gif" width="377" align="left" border="0" /><b><span style="FONT-FAMILY: Tahoma"><font color="#0000ff" size="2"></font></span><font color="#000080"><span style="FONT-SIZE: 14pt; FONT-FAMILY: Times New Roman">
    </span></font></b></p>
    </td>
  </tr>
  
  
  <tr>
    <td width="193" height="22" " align=">
    <p align="left"><font color="#000080" size="2" face="Tahoma"><b>From</b></font></p>
    </td>
    <td  height="22" align="left" width="215"><font size="2" color="#000080">
    <span style="font-family: Tahoma; font-weight: 700">Object</span></font></td>
    <td height="22" align="left" width="85"><b>
    <font face="Tahoma" size="2" color="#000080">Attached File</font></b></td>
    <td height="22" width="156"><font color="#000080" size="2" face="Tahoma"><b>
    Date</b></font></td>
    <td height="22" width="80">
  
      <input type="submit" value="Delete" name="B3" style="font-size: 8pt; font-weight: bold; float: right; background-color: #FF6666" /><p>
      </p>
    
    </td>
  </tr>
<%
             }
             
             count3++;
             projid = rs2.getString("MEMOID");
             String author = rs2.getString("CREATORID");
		 	 String tmp = rs2.getString("CREATIONDATE");
		 	 String date= tmp.substring(0,4)+"/"+tmp.substring(4,6)+"/"+tmp.substring(6,8);
			 String attachment = rs2.getString("ATTACHID");
             projname = rs2.getString("SUBJECT");
             projdesc = rs2.getString("TEXT");
            %> <%
             
             ResultSet rs1;
            

        %>
  
  	<%
  	 rs1 = query2.queryUser("USERID",author);
              while (rs1.next())
              {%>
            <tr>
    		<td width="147" height="22" style="border-left-width: 1; border-right-width: 1; padding: 0" bgcolor="#FFFFFF">
    		<span style="font-size: 10pt; font-family: Times New Roman">
    		<font color="#0000FF"><u><a href="ECNUserInfo.jsp?userid=<%= rs1.getString("USERID")%>"><%=rs1.getString("FIRSTNAME")+" "+rs1.getString("LASTNAME") %></u></font></span></td>
    		
    		
    		
    		<td width="120" height="22" style="border-left-width: 1; border-right-width: 1; padding: 0" bgcolor="#FFFFFF">
    		<%}%>
    		
    
 
    <span style="font-size: 10pt; font-family: Times New Roman">
    <a href="ECNMyMemo.jsp?projid=<%=projid%>&projname=<%=projname%>&projdesc=<%=projdesc%>&author=<%=author%>">
    <%= projname %> </a></span></td>
    <span style="font-size: 10pt; font-family: Times New Roman">
    <td width="176" height="22" style="border-left-width: 1; border-right-width: 1; padding: 0" bgcolor="#FFFFFF">
    
    <% if (attachment.compareTo("0")!=0)
    {%>
    <font size="2"><span style="font-family: Times New Roman"><a href="../servlet/Mimap.ECNDownloadDocument?docid=<%=attachment%>">Download </span>
    <%} else {%>
    <font size="2"><span style="font-family: Times New Roman">Without </span>
    <%}%>
    </font></td>
    <td width="145" height="22" style="border-left-width: 1; border-right-width: 1; padding: 0" bgcolor="#FFFFFF">
    </span>
    <span align="center" style="font-size: 10pt; font-family: Times New Roman" style="font-size: 10pt; font-family: Times New Roman">
    <%= date %> </span>
            </td>
    <td width="123" style="border-left-width: 1; border-right-width: 1; padding: 0" bgcolor="#FFFFFF" height="22" align="center">
    </span>
    <p align="center">
    <span align="center" style="font-size: 10pt; font-family: Times New Roman">
    <input type="checkbox" name="<%=projid%>" value="<%=projid%>" style="float: right" /></span></p>
    </td>
  
    
  </tr>
   
  
  <%}
  
  
  
  
  
  
   if (count3>0){%>
   </form>
</table>
<%}%>



<table height="94" width="616">
  <% if (count==0 && count1==0 && count11==0 && count2==0)
  {
  %>
  <tr>
    <td valign="top" width="610" height="34"></td>
  </tr>
  <tr>
    <td valign="top" width="610" height="15"></span>
    <ul>
      <li><span style="font-size: 10pt; font-family: Tahoma; font-weight:700">
    <font color="#0000FF" size="2">You're working space is currently empty. If 
      you are a new member, we invitate you to update your personal information 
      from the submenu Personal Setting.</font></span></li>
    </ul>
    </td>
  </tr>
  <% 
	}
	ResultSet infoUser;
	infoUser = query2.queryUser2("USERID",userid);
		while(infoUser.next())
	{
	if (infoUser.getString("CV")==null)
		{%>
  <tr>
      <td vAlign="top" width="616" height="1">&nbsp;</td>
    </tr><tr>
    <td valign="top" width="610" height="15"></span>
    <ul>
      <li><span style="font-size: 10pt; font-family: Tahoma; font-weight:700">
    <font color="#0000FF" size="2">Your CV is currently unavailable. For futher 
    informations consult the personal setting page</font></span></li>
    </ul>
    </td>
  </tr>
  <%
		}
     if (infoUser.getString("ADDRESS")==null && infoUser.getString("CITY")==null && infoUser.getString("STATE")==null)
		{%>
  <tr>
    <td valign="top" width="610" height="15"></span>
    <p></p>
    </td>
  </tr>
  <%
		}
	}
	
%> 

</body>

</html>