

package Mimap.forum.DB;

import java.util.*;

public class ForumData {
  int id;
  String name;
  String descr;
  Date modify;
  int tcount;
  int mcount;

    public ForumData() {}

    public int getID() {
    return id;
  }

    public void setID(int id) {
    this.id = id;
  }

    public String getName() {
    return name;
  }

   public void setName(String name) {
    this.name = name;
  }

    public String getDescription() {
    return descr;
  }

    public void setDescription(String descr) {
    this.descr = descr;
  }

    public Date getTimestamp() {
    return modify;
  }

    public void setTimestamp(Date modify) {
    this.modify = modify;
  }

   public int getThreadCount() {
    return tcount;
  }

    public void setThreadCount(int count) {
    tcount = count;
  }

   public int getMessageCount() {
    return mcount;
  }

  
  public void setMessageCount(int count) {
    mcount = count;
  }
}
