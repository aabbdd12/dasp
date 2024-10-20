

package Mimap.forum.DB.support;

import java.sql.*;
import Mimap.forum.*;
import Mimap.forum.DB.*;
import Mimap.forum.support.VectorIterator;

public class ForumDB extends SequenceDB {
  static final String[] SORT_KEY = {Forum.FORUM_ORDER_NAME,
	Forum.FORUM_ORDER_DATE, Forum.FORUM_ORDER_TCOUNT,
	Forum.FORUM_ORDER_MCOUNT};
  static final String[] ORDER_BY_CLAUSE = {"name asc", "modify desc",
	"tcount desc, modify desc", "mcount desc, modify desc"};
  int defaultSortKey = 0;
  int sortKey = defaultSortKey;
  int tid;
  int mid;

  public ForumDB() {
    setTableName("forum");
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

  public int getThreadID() {
    return tid;
  }

  public int getMessageID() {
    return mid;
  }

  public ForumData getForum(Connection con, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery(
	"select * from " + tableName + " where id=" + id);
      if (!rs.next()) throw new IllegalDataException("forum.noforum", id);
      return readData(rs);
    } finally {
      s.close();
    }
  }

  public VectorIterator getForums(Connection con) throws SQLException {
    Statement s = con.createStatement();

    try {
      ResultSet rs = s.executeQuery(
	"select * from " + tableName + " order by " + ORDER_BY_CLAUSE[sortKey]);
      VectorIterator v = new VectorIterator();
      while (rs.next())
	v.add(readData(rs));
      return v;
    } finally {
      s.close();
    }
  }

  public int insert(Connection con, String name, String descr)
	throws SQLException {
    int id = nextSequenceValue(con);
    PreparedStatement ps = con.prepareStatement(
	"insert into " + tableName + " (id, name, descr, modify) values ("
	+ id + ", ?, ?, current_timestamp)");

    try {
      ps.setString(1, name);
      ps.setString(2, descr);
      ps.executeUpdate();
      return id;
    } finally {
      ps.close();
    }
  }

  public void delete(Connection con, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      int c = s.executeUpdate("delete from " + tableName + " where id=" + id);
      if (c != 1) throw new IllegalDataException("forum.noforum", id);
    } finally {
      s.close();
    }
  }

  public void allocateThreadMessage(Connection con, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      s.executeUpdate("update " + tableName
	+ " set modify=current_timestamp, tcount=tcount+1, mcount=mcount+1,"
	+ " tseq=tseq+1, mseq=mseq+1 where id=" + id);
      ResultSet rs = s.executeQuery(
	"select tseq, mseq from " + tableName + " where id=" + id);
      if (!rs.next()) throw new IllegalDataException("forum.noforum", id);
      tid = rs.getInt(1);
      mid = rs.getInt(2);
    } finally {
      s.close();
    }
  }

  public int allocateThread(Connection con, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      s.executeUpdate("update " + tableName + " set modify=current_timestamp,"
	+ " tcount=tcount+1, tseq=tseq+1 where id=" + id);
      ResultSet rs = s.executeQuery(
	"select tseq from " + tableName + " where id=" + id);
      if (!rs.next()) throw new IllegalDataException("forum.noforum", id);
      return rs.getInt(1);
    } finally {
      s.close();
    }
  }

  public int allocateMessage(Connection con, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      s.executeUpdate("update " + tableName + " set modify=current_timestamp,"
	+ " mcount=mcount+1, mseq=mseq+1 where id=" + id);
      ResultSet rs = s.executeQuery(
	"select mseq from " + tableName + " where id=" + id);
      if (!rs.next()) throw new IllegalDataException("forum.noforum", id);
      return rs.getInt(1);
    } finally {
      s.close();
    }
  }

  public void deleteThread(Connection con, int id)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      int c = s.executeUpdate(
	"update " + tableName + " set tcount=tcount-1 where id=" + id);
      if (c != 1) throw new IllegalDataException("forum.noforum", id);
    } finally {
      s.close();
    }
  }

  public void deleteMessage(Connection con, int id, int count)
	throws SQLException, IllegalDataException {
    Statement s = con.createStatement();

    try {
      int c = s.executeUpdate("update " + tableName
	+ " set mcount=mcount-" + count + " where id=" + id);
      if (c != 1) throw new IllegalDataException("forum.noforum", id);
    } finally {
      s.close();
    }
  }

  public void reset() {
    sortKey = defaultSortKey;
  }

  protected ForumData readData(ResultSet rs) throws SQLException {
    ForumData data = new ForumData();
    data.setID(rs.getInt(1));
    data.setName(rs.getString(2));
    data.setDescription(rs.getString(3));
    data.setTimestamp(rs.getTimestamp(4));
    data.setThreadCount(rs.getInt(5));
    data.setMessageCount(rs.getInt(6));
    return data;
  }
}
