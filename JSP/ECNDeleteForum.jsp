<jsp:useBean id="forum" class="Mimap.forum.DB.Forum" />
<% Mimap.forum.Customizer.customize(forum, "Forum"); %>

<jsp:setProperty name="forum" property="forumID" param="fid" />

<%
  forum.deleteForum();

  response.sendRedirect("ECNAdminCreateForum.jsp");
%>
