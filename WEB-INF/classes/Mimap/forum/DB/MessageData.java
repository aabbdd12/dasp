

package Mimap.forum.DB;

import java.util.*;

public class MessageData {
  int fid;
  int id;
  int tid;
  int rid;
  String subject;
  String body;
  String author;
  String email;
  String homepage;
  Date post;
  int level = 0;

   public MessageData() {}

   public int getForumID() {
    return fid;
  }

   public void setForumID(int fid) {
    this.fid = fid;
  }

    public int getID() {
    return id;
  }

    public void setID(int id) {
    this.id = id;
  }

  /**
  * Gets the thread ID of the message.
  *
  * @return	the thread ID
  */
  public int getThreadID() {
    return tid;
  }

  /**
  * Sets the thread ID of the message.
  *
  * @param tid	the thread ID
  */
  public void setThreadID(int tid) {
    this.tid = tid;
  }

  /**
  * Gets the ID of the message to which this message replies.
  *
  * @return	the ID; 0 if no such message exists.
  */
  public int getReplyToID() {
    return rid;
  }

  /**
  * Sets the ID of the message to which this message replies.
  *
  * @param rid	the ID
  */
  public void setReplyToID(int rid) {
    this.rid = rid;
  }

  /**
  * Gets the subject of the message.
  *
  * @return	the subject
  */
  public String getSubject() {
    return subject;
  }

  /**
  * Sets the subject of the message.
  *
  * @param subject	the subject
  */
  public void setSubject(String subject) {
    this.subject = subject;
  }

  /**
  * Gets the body of the message.
  *
  * @return	the message body
  */
  public String getBody() {
    return body;
  }

  /**
  * Sets the body of the message.
  *
  * @param body	the message body
  */
  public void setBody(String body) {
    this.body = body;
  }

  /**
  * Gets the name of the author of the message.
  *
  * @return	the name
  */
  public String getAuthor() {
    return author;
  }

  /**
  * Sets the name of the author of the message.
  *
  * @param author	the name
  */
  public void setAuthor(String author) {
    this.author = author;
  }

  /**
  * Gets the e-mail address of the author of the message.
  *
  * @return	the e-mail address
  */
  public String getEmail() {
    return email;
  }

  /**
  * Sets the e-mail address of the author of the message.
  *
  * @param email	the e-mail address
  */
  public void setEmail(String email) {
    this.email = email;
  }

  /**
  * Gets the homepage location of the author of the message.
  *
  * @return	the homepage location
  */
  public String getHomepage() {
    return homepage;
  }

  /**
  * Sets the homepage location of the author of the message.
  *
  * @param homepage	the homepage location
  */
  public void setHomepage(String homepage) {
    this.homepage = homepage;
  }

  /**
  * Gets the timestamp when the message was posted.
  *
  * @return	the timestamp
  */
  public Date getTimestamp() {
    return post;
  }

  /**
  * Sets the timestamp when the message was posted.
  *
  * @param post	the timestamp
  */
  public void setTimestamp(Date post) {
    this.post = post;
  }

  /**
  * Gets the level of the message. The original post is at level 0, it's direct
  * replies are at level 1, and so on. This value is set automatically only
  * when messages are sorted by thread. (See
  * <code>Forum.MESSAGE_ORDER_THREAD</code>)
  *
  * @return	the level
  */
  public int getLevel() {
    return level;
  }

  /**
  * Sets the level of the message. The original post is at level 0, it's direct
  * replies are at level 1, and so on.
  *
  * @param level	the level
  */
  public void setLevel(int level) {
    this.level = level;
  }

  /**
  * Gets the body of the message with indentation so that it can be included in
  * a reply message clearly.
  *
  * @return	the indented message body
  */
  public String getIndentedBody() {
    StringBuffer sb = new StringBuffer();
    StringTokenizer st = new StringTokenizer(body, "\n");
    while (st.hasMoreTokens())
      sb.append("> ").append(st.nextToken()).append("\n");
    return sb.toString();
  }
}
