<%@ page import="Mimap.forum.DB.*" %>

<table width="654">
   <tr>
      <td style="PADDING-RIGHT: 0cm; BACKGROUND-POSITION: 0% 50%; PADDING-LEFT: 0cm; BACKGROUND-ATTACHMENT: scroll; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm; BACKGROUND-REPEAT: repeat; BACKGROUND-COLOR: #e4e9ff" width="650" height="1">
        <p class="MsoNormal" align="left"><b><font size="4">Current Forums</font></b></p>
      </td>
      </form>
    </tr>
</table>


<dl>

<jsp:useBean id="forum" class="Mimap.forum.DB.Forum" />


<% 
Mimap.forum.Customizer.customize(forum, "Forum"); %>

<%
  java.text.DateFormat format
	= new java.text.SimpleDateFormat("yyyy-MM-dd h:mm a");

  forum.readForums();
  while (forum.hasNextResult()) {
    ForumData data = (ForumData)forum.nextResult();
%>

  <dt><a href=ECNUserForum.jsp?fid=<%= data.getID() %>&user=admin><%= data.getName() %></a>
    <i>(<%= data.getThreadCount() %> threads,
    <%= data.getMessageCount() %> messages)
    last modified <%= format.format(data.getTimestamp()) %></i>
  <dd><%= data.getDescription() %><p>

<%
  }
%>

</dl>

<hr>
<table width="654">
   <tr>
      <td style="PADDING-RIGHT: 0cm; BACKGROUND-POSITION: 0% 50%; PADDING-LEFT: 0cm; BACKGROUND-ATTACHMENT: scroll; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm; BACKGROUND-REPEAT: repeat; BACKGROUND-COLOR: #e4e9ff" width="650" height="1">
        <p class="MsoNormal" align="left"><b><font size="4">Create Forum</font></b></p>
      </td>
      </form>
    </tr>
</table>
<form action=create_forum.jsp method=post>
<table><tr>
  <td>Name
  <td><input name=name type=text size=40 maxlength=40>
<tr>
  <td>Description
  <td><textarea name=descr rows=5 cols=40></textarea>
<tr>
  <td colspan=2 align=right>
    <input type=submit value="Create">
    <input type=reset value=" Clear ">
</table>
</form>