

package Mimap.forum.DB.support;

import java.sql.*;

public class SequenceDB extends BasicDB {
  String seqTableName = "sequence";

  public String getSequenceTableName() {
    return seqTableName;
  }

  public void setSequenceTableName(String tableName) {
    seqTableName = tableName;
  }

  public int nextSequenceValue(Connection con) throws SQLException {
    Statement s = con.createStatement();

    try {
      if (s.executeUpdate("update " + seqTableName
		+ " set seq=seq+1 where name='" + tableName + "'") == 0)
	s.executeUpdate("insert into " + seqTableName
		+ " (name) values ('" + tableName + "')");

      ResultSet rs = s.executeQuery(
	"select seq from " + seqTableName + " where name='" + tableName + "'");
      rs.next();
      return rs.getInt(1);
    } finally {
      s.close();
    }
  }
}
