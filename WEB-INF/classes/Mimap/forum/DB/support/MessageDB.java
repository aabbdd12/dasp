

package Mimap.forum.DB.support;

import java.sql.*;
import Mimap.forum.*;
import Mimap.forum.DB.*;
import Mimap.forum.support.VectorIterator;

public class MessageDB extends BasicDB {
  static final String[] SORT_KEY = {Forum.MESSAGE_ORDER_THREAD,
	Forum.MESSAGE_ORDER_DATE, Forum.MESSAGE_ORDER_AUTHOR};
  static final String[] ORDER_BY_CLAUSE
	= {"id asc", "id asc", "author asc, id asc"};
  int defaultSortKey = 0;
  int sortKey = defaultSortKey;
  int defaultPageSize = 20;
  int pageSize = defaultPageSize;
  int page = 1;
  int resultCount = 0;

  public MessageDB() {
    setTableName("message");
  }

  public String getDefaultSortKey() {
    return SORT_KEY[defaultSortKey];
  }

  public void setDefaultSortKey(String sortKey) {
    for (int i = 0; i < SORT_KEY.length; i++)
      if (sortKey.compareToIgnoreCase(SORT_KEY[i]) == 0) {
	this.sortKey = defaultSortKey = i;
	break;
      }
  }

  public void setSortKey(String sortKey) {
    for (int i = 0; i < SORT_KEY.length; i++)
      if (sortKey.compareToIgnoreCase(SORT_KEY[i]) == 0) {
	this.sortKey = i;
	break;
      }
  }

  public int getDefaultPageSize() {
    return defaultPageSize;
  }

  public void setDefaultPageSize(int pageSize) {
    this.pageSize = defaultPageSize = pageSize > 0 ? pageSize : 0;
  }

  public int getPageSize() {
    return pageSize;
  }

  public void setPageSize(int pageSize) {
    this.pageSize = pageSize > 0 ? pageSize : 0;
  }

  public int getPage() {
    return page;
  }

  public void setPage(int page) {
    this.page = page > 0 ? page : 1;
  }

  public int getResultCount() {
    return resultCount;
  }

  public MessageData getMessage(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery(
	"select * from " + tableName + " where forum=" + fid + " and id=" + id);
      if (!rs.next())
	throw new IllegalDataException("forum.nomessage", fid, id);
      return  readData(rs);
    } finally {
      s.close();
    }
  }

  public MessageData getNextMessage(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery("select m2.* from " + tableName + " m1, "
	+ tableName + " m2 where m1.forum=" + fid + " and m1.id=" + id
	+ " and m2.forum=m1.forum and m2.thread=m1.thread and"
	+ " m2.replyto=m1.replyto and m2.id>=m1.id order by id asc");
      if (!rs.next())
	throw new IllegalDataException("forum.nomessage", fid, id);
      return rs.next() ? readData(rs) : null;
    } finally {
      s.close();
    }
  }

  public MessageData getPreviousMessage(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery("select m2.* from " + tableName + " m1, "
	+ tableName + " m2 where m1.forum=" + fid + " and m1.id=" + id
	+ " and m2.forum=m1.forum and m2.thread=m1.thread and"
	+ " m2.replyto=m1.replyto and m2.id<=m1.id order by id desc");
      if (!rs.next())
	throw new IllegalDataException("forum.nomessage", fid, id);
      return rs.next() ? readData(rs) : null;
    } finally {
      s.close();
    }
  }

  public VectorIterator getMessages(Connection con, int fid, int tid)
	throws SQLException {
    VectorIterator v;
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery(
	"select * from " + tableName + " where forum=" + fid
	+ " and thread=" + tid + " order by " + ORDER_BY_CLAUSE[sortKey]);
      for (v = new VectorIterator(); rs.next();)
	v.add(readData(rs));
    } finally {
      s.close();
    }

    if (sortKey == 0)
      for (int i = 0; i < v.size(); i++) {
	MessageData msg = (MessageData)v.get(i);
	int id = msg.getID();
	int level = msg.getLevel() + 1;
	int c = 0;
	for (int j = i + 1; j < v.size(); j++)
	  if ((msg = (MessageData)v.get(j)).getReplyToID() == id) {
	    msg.setLevel(level);
	    v.add(i + ++c, v.remove(j));
	  }
      }

    return v;
  }

  public VectorIterator getReplies(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery("select m2.* from " + tableName + " m1, "
	+ tableName + " m2 where m1.forum=" + fid + " and m1.id=" + id
	+ " and m2.forum=m1.forum and (m2.id=m1.id or (m2.thread=m1.thread"
	+ " and m2.replyto=m1.id)) order by id asc");
      if (!rs.next())
	throw new IllegalDataException("forum.nomessage", fid, id);
      VectorIterator v = new VectorIterator();
      while (rs.next())
	v.add(readData(rs));
      return v;
    } finally {
      s.close();
    }
  }

  public VectorIterator search(Connection con, int fid, String phrase)
	throws SQLException {
    PreparedStatement ps = con.prepareStatement("select * from " + tableName
	+ " where"+ (fid > 0 ? " forum=" + fid + " and" : "")
	+ " (subject like ? or body like ?) order by post desc");

    try {
      ps.setString(1, "%" + phrase + "%");
      ps.setString(2, "%" + phrase + "%");
      ResultSet rs = ps.executeQuery();
      resultCount = 0;
      int i;
      for (i = (page - 1) * pageSize; i > 0 && rs.next(); i--)
	resultCount++;
      VectorIterator v = new VectorIterator();
      if (i <= 0) {
	i = 0;
	while (rs.next()) {
	  v.add(readData(rs));
	  resultCount++;
	  if (++i == pageSize) {
	    while (rs.next())
	      resultCount++;
	    break;
	  }
	}
      }
      return v;
    } finally {
      ps.close();
    }
  }

  public void insert(Connection con, int fid, int id, int tid, int rid,
	String subject, String body, String author, String email,
	String homepage) throws SQLException {
    PreparedStatement ps = con.prepareStatement(
	"insert into " + tableName + " (forum, id, thread, replyto, subject,"
	+ " body, author, email, homepage, post) values (" + fid + ", "+ id
	+ ", " + tid + ", " + rid + ", ?, ?, ?, ?, ?, current_timestamp)");

    try {
      ps.setString(1, subject);
      ps.setString(2, body);
      ps.setString(3, author);
      ps.setString(4, email);
      ps.setString(5, homepage);
      ps.executeUpdate();
    } finally {
      ps.close();
    }
  }

  public int delete(Connection con, int fid) throws SQLException {
    Statement s = con.createStatement();

    try {
      return s.executeUpdate(
	"delete from " + tableName + " where forum=" + fid);
    } finally {
      s.close();
    }
  }

  public int delete(Connection con, int fid, int tid) throws SQLException {
    Statement s = con.createStatement();

    try {
      return s.executeUpdate("delete from " + tableName
	+ " where forum=" + fid + " and thread=" + tid);
    } finally {
      s.close();
    }
  }

  public int delete(Connection con, int fid, int id, int tid)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      String temp = tableName + "_" + fid + "_" + id;
      s.executeUpdate(
	"create table " + temp + " (id int not null, i int not null)");

      try {
	s.executeUpdate("insert into " + temp + " values (" + id + ", 0)");
	for (int i = 0; s.executeUpdate("insert into " + temp
		+ " select id, " + (i + 1) + " from " + tableName
		+ " where forum=" + fid + " and thread=" + tid
		+ " and replyto in (select id from " + temp
		+ " where i=" + i + ")") > 0; i++);
	int c = s.executeUpdate("delete from " + tableName + " where forum="
		+ fid + " and id in (select id from " + temp + ")");
	if (c < 1)
	  throw new IllegalDataException("forum.nomessage", fid, id);
	return c;
      } finally {
	s.executeUpdate("drop table " + temp);
      }
    } finally {
      s.close();
    }
  }

  public void delete(Connection con, int fid, int id, int tid, int rid)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      s.executeUpdate("update " + tableName + " set replyto=" + rid
	+ " where forum=" + fid + " and thread=" + tid + " and replyto=" + id);
      int c = s.executeUpdate(
	"delete from " + tableName + " where forum=" + fid + " and id=" + id);
      if (c != 1)
	throw new IllegalDataException("forum.nomessage", fid, id);
    } finally {
      s.close();
    }
  }

  public void reset() {
    sortKey = defaultSortKey;
    pageSize = defaultPageSize;
    page = 1;
    resultCount = 0;
  }

  protected MessageData readData(ResultSet rs) throws SQLException {
    MessageData data = new MessageData();
    data.setForumID(rs.getInt(1));
    data.setID(rs.getInt(2));
    data.setThreadID(rs.getInt(3));
    data.setReplyToID(rs.getInt(4));
    data.setSubject(rs.getString(5));
    data.setBody(rs.getString(6));
    data.setAuthor(rs.getString(7));
    data.setEmail(rs.getString(8));
    data.setHomepage(rs.getString(9));
    data.setTimestamp(rs.getTimestamp(10));
    return data;
  }
}
