

package Mimap.forum.DB.support;

import java.sql.*;
import Mimap.forum.*;
import Mimap.forum.DB.*;
import Mimap.forum.support.VectorIterator;

public class ThreadDB extends BasicDB {
  static final String[] SORT_KEY = {Forum.THREAD_ORDER_DATE,
	Forum.THREAD_ORDER_SUBJECT, Forum.THREAD_ORDER_MCOUNT};
  static final String[] ORDER_BY_CLAUSE
	= {"modify desc", "subject asc", "count desc"};
  int defaultSortKey = 0;
  int sortKey = defaultSortKey;
  int defaultPageSize = 20;
  int pageSize = defaultPageSize;
  int page = 1;

  public ThreadDB() {
    setTableName("thread");
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

  public ThreadData getThread(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery(
	"select * from " + tableName + " where forum=" + fid + " and id=" + id);
      if (!rs.next()) throw new IllegalDataException("forum.nothread", fid, id);
      return readData(rs);
    } finally {
      s.close();
    }
  }

  public ThreadData getNextThread(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery("select * from " + tableName
	+ " where forum=" + fid + " and id>=" + id + " order by id asc");
      if (!rs.next() || readData(rs).getID() != id)
	throw new IllegalDataException("forum.nothread", fid, id);
      return rs.next() ? readData(rs) : null;
    } finally {
      s.close();
    }
  }

  public ThreadData getPreviousThread(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery("select * from " + tableName
	+ " where forum=" + fid + " and id<=" + id + " order by id desc");
      if (!rs.next() || readData(rs).getID() != id)
	throw new IllegalDataException("forum.nothread", fid, id);
      return rs.next() ? readData(rs) : null;
    } finally {
      s.close();
    }
  }

  public VectorIterator getThreads(Connection con, int fid)
	throws SQLException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery("select * from " + tableName
	+ " where forum=" + fid + " order by " + ORDER_BY_CLAUSE[sortKey]);
      int i;
      for (i = (page - 1) * pageSize; i > 0 && rs.next(); i--);
      VectorIterator v = new VectorIterator();
      if (i <= 0) {
	i = 0;
	while (rs.next()) {
	  v.add(readData(rs));
	  if (++i == pageSize) break;
	}
      }
      return v;
    } finally {
      s.close();
    }
  }

  public void insert(Connection con, int fid, int id, String subject, int count)
	throws SQLException {
    PreparedStatement ps = con.prepareStatement("insert into " + tableName
	+ " (forum, id, subject, count, modify) values ("
	+ fid + ", " + id + ", ?, " + count + ", current_timestamp)");

    try {
      ps.setString(1, subject);
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

  public void delete(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      int c = s.executeUpdate(
	"delete from " + tableName + " where forum=" + fid + " and id=" + id);
      if (c != 1) throw new IllegalDataException("forum.nothread", fid, id);
    } finally {
      s.close();
    }
  }

  public void addMessage(Connection con, int fid, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      int c = s.executeUpdate("update " + tableName
	+ " set count=count+1, modify=current_timestamp where forum="
	+ fid + " and id=" + id);
      if (c != 1) throw new IllegalDataException("forum.nothread", fid, id);
    } finally {
      s.close();
    }
  }

  public void deleteMessage(Connection con, int fid, int id, int count)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      //int c = s.executeUpdate("update " + tableName + " set count=count-"
	//+ count + ", modify=current_timestamp where forum=" + fid
	//+ " and id=" + id);
      int c = s.executeUpdate("update " + tableName + " set count=count-"
	+ count + " where forum=" + fid + " and id=" + id);
      if (c != 1) throw new IllegalDataException("forum.nothread", fid, id);
    } finally {
      s.close();
    }
  }

  public void reset() {
    sortKey = defaultSortKey;
    pageSize = defaultPageSize;
    page = 1;
  }

  protected ThreadData readData(ResultSet rs) throws SQLException {
    ThreadData data = new ThreadData();
    data.setForumID(rs.getInt(1));
    data.setID(rs.getInt(2));
    data.setSubject(rs.getString(3));
    data.setMessageCount(rs.getInt(4));
    data.setTimestamp(rs.getTimestamp(5));
    return data;
  }
}
