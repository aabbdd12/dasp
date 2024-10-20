

package Mimap.forum.DB;

import java.util.*;

/**
* A <code>ThreadData</code> object stores the information of a thread of
* messages in a forum.
*
* @see	Forum
*/
public class ThreadData {
  int fid;
  int id;
  String subject;
  int mcount;
  Date modify;

  /**
  * Constructs a <code>ThreadData</code> object.
  */
  public ThreadData() {}

  /**
  * Gets the forum ID of the thread.
  *
  * @return	the forum ID
  */
  public int getForumID() {
    return fid;
  }

  /**
  * Sets the forum ID of the thread.
  *
  * @param fid	the forum ID
  */
  public void setForumID(int fid) {
    this.fid = fid;
  }

  /**
  * Gets the ID of the thread.
  *
  * @return	the ID
  */
  public int getID() {
    return id;
  }

  /**
  * Sets the ID of the thread.
  *
  * @param id	the ID
  */
  public void setID(int id) {
    this.id = id;
  }

  /**
  * Gets the subject of the thread.
  *
  * @return	the subject
  */
  public String getSubject() {
    return subject;
  }

  /**
  * Sets the subject of the thread.
  *
  * @param subject	the subject
  */
  public void setSubject(String subject) {
    this.subject = subject;
  }

  /**
  * Gets the number of messages in the thread.
  *
  * @return	the number of messages
  */
  public int getMessageCount() {
    return mcount;
  }

  /**
  * Sets the number of messages in the thread.
  *
  * @param count	the number of messages
  */
  public void setMessageCount(int count) {
    mcount = count;
  }

  /**
  * Gets the timestamp when the thread was last modified.
  *
  * @return	the timestamp
  */
  public Date getTimestamp() {
    return modify;
  }

  /**
  * Sets the timestamp when the thread was last modified.
  *
  * @param modify	the timestamp
  */
  public void setTimestamp(Date modify) {
    this.modify = modify;
  }
}
