

package Mimap.forum.DB;

import java.sql.*;
import java.util.Vector;
import Mimap.DADDBConnection;
import Mimap.forum.*;
import Mimap.forum.support.VectorIterator;
import Mimap.forum.DB.support.*;


public class Forum implements Customizee, ResultIterator {

  /**
  * Forums are sorted by name in ascending order. The value of this constant is
  * "name".
  */
  public static final String FORUM_ORDER_NAME = "name";

  /**
  * Forums are sorted by modification timestamp in descending order. The value
  * of this constant is "date".
  */
  public static final String FORUM_ORDER_DATE = "date";

  /**
  * Forums are sorted by number of threads in descending order. The value of
  * this constant is "thread_count".
  */
  public static final String FORUM_ORDER_TCOUNT = "thread_count";

  /**
  * Forums are sorted by number of messages in descending order. The value of
  * this constant is "message_count".
  */
  public static final String FORUM_ORDER_MCOUNT = "message_count";

  /**
  * Threads are sorted by modification timestamp in descending order. The value
  * of this constant is "date".
  */
  public static final String THREAD_ORDER_DATE = "date";

  /**
  * Threads are sorted by subject in ascending order. The value of this
  * constant is "subject".
  */
  public static final String THREAD_ORDER_SUBJECT = "subject";

  /**
  * Threads are sorted by number of messages in descending order. The value of
  * this constant is "message_count".
  */
  public static final String THREAD_ORDER_MCOUNT = "message_count";

  /**
  * Messages are sorted by thread. The value of this constant is "thread".
  */
  public static final String MESSAGE_ORDER_THREAD = "thread";

  /**
  * Messages are sorted by posting timestamp in ascending order. The value of
  * this constant is "date".
  */
  public static final String MESSAGE_ORDER_DATE = "date";

  /**
  * Messages are sorted by author's name in ascending order. The value of this
  * constant is "author".
  */
  public static final String MESSAGE_ORDER_AUTHOR = "author";

  String dbConBeanName = "Mimap.forum.DataSourceConnection";
  int fid = 0;
  int tid = 0;
  int mid = 0;
  int newMID = 0;
  String name = "";
  String descr = "";
  String subject = "";
  String body = "";
  String author = "";
  String email = "";
  String homepage = "";
  String phrase = "";
  ForumData forum = null;
  ThreadData thread = null;
  MessageData message = null;
  VectorIterator results = null;
  int pageCount = 0;
  boolean neighbourThreadsRead = false;
  boolean neighbourMessagesRead = false;
  ThreadData nextThread = null;
  ThreadData prevThread = null;
  MessageData nextMessage = null;
  MessageData prevMessage = null;
  ForumDB fdb = new ForumDB();
  ThreadDB tdb = new ThreadDB();
  MessageDB mdb = new MessageDB();

  /**
  * Constructs a <code>Forum</code> object.
  */
  public Forum() {}

  /**
  * Gets the name of the bean that provides access to a database.
  *
  * @return	the bean name
  */
  public String getDbConnectionBeanName() {
    return dbConBeanName;
  }

  /**
  * Sets the name of the bean that provides access to a database. The bean can
  * be either a serialized object or a class and must be a subtype of
  * <code>DBConnection</code>.
  *
  * @param dbConBeanName	the bean name
  * @see			DBConnection
  */
  public void setDbConnectionBeanName(String dbConBeanName) {
    this.dbConBeanName = dbConBeanName;
  }

  /**
  * Gets the table name of the forum data.
  *
  * @return	the table name
  */
  public String getForumTableName() {
    return fdb.getTableName();
  }

  /**
  * Sets the table name of the forum data.
  *
  * @param tableName	the table name
  */
  public void setForumTableName(String tableName) {
    fdb.setTableName(tableName);
  }

  /**
  * Gets the table name of the thread data.
  *
  * @return	the table name
  */
  public String getThreadTableName() {
    return tdb.getTableName();
  }

  /**
  * Sets the table name of the message data.
  *
  * @param tableName	the table name
  */
  public void setThreadTableName(String tableName) {
    tdb.setTableName(tableName);
  }

  /**
  * Gets the table name of the message data.
  *
  * @return	the table name
  */
  public String getMessageTableName() {
    return mdb.getTableName();
  }

  /**
  * Sets the table name of the message data.
  *
  * @param tableName	the table name
  */
  public void setMessageTableName(String tableName) {
    mdb.setTableName(tableName);
  }

  /**
  * Gets the table name of the sequence data.
  *
  * @return	the table name
  */
  public String getSequenceTableName() {
    return fdb.getSequenceTableName();
  }

  /**
  * Sets the table name of the sequence data.
  *
  * @param tableName	the table name
  */
  public void setSequenceTableName(String tableName) {
    fdb.setSequenceTableName(tableName);
  }

  /**
  * Gets the default value for the sort key by which the results produced by
  * the method <code>readForums</code> are sorted.
  *
  * @return	the current default FORUM_ORDER_* value
  */
  public String getDefaultForumSortKey() {
    return fdb.getDefaultSortKey();
  }

  /**
  * Sets the default value for the sort key by which the results produced by
  * the method <code>readForums</code> are sorted.
  *
  * @param sortKey	one of the FORUM_ORDER_* values
  * @see		#setForumSortKey
  */
  public void setDefaultForumSortKey(String sortKey) {
    fdb.setDefaultSortKey(sortKey);
  }

  /**
  * Gets the default value for the sort key by which the results produced by
  * the method <code>readThreads</code> are sorted.
  *
  * @return	the current default THREAD_ORDER_* value
  */
  public String getDefaultThreadSortKey() {
    return tdb.getDefaultSortKey();
  }

  /**
  * Sets the default value for the sort key by which the results produced by
  * the method <code>readThreads</code> are sorted.
  *
  * @param sortKey	one of the THREAD_ORDER_* values
  * @see		#setThreadSortKey
  */
  public void setDefaultThreadSortKey(String sortKey) {
    tdb.setDefaultSortKey(sortKey);
  }

  /**
  * Gets the default value for the number of threads that a page in the results
  * produced by the method <code>readThreads</code> can holds.
  *
  * @return	the page size
  */
  public int getDefaultThreadPageSize() {
    return tdb.getDefaultPageSize();
  }

  /**
  * Sets the default value for the number of threads that a page in the results
  * produced by the method <code>readThreads</code> can holds.
  *
  * @param pageSize	the page size
  * @see		#setThreadPageSize
  */
  public void setDefaultThreadPageSize(int pageSize) {
    tdb.setDefaultPageSize(pageSize);
  }

  /**
  * Gets the default value for the sort key by which the results produced by
  * the method <code>readMessages</code> are sorted.
  *
  * @return	the current default MESSAGE_ORDER_* value
  */
  public String getDefaultMessageSortKey() {
    return mdb.getDefaultSortKey();
  }

  /**
  * Sets the default value for the sort key by which the results produced by
  * the method <code>readMessages</code> are sorted.
  *
  * @param sortKey	one of the MESSAGE_ORDER_* values
  * @see		#setMessageSortKey
  */
  public void setDefaultMessageSortKey(String sortKey) {
    mdb.setDefaultSortKey(sortKey);
  }

  /**
  * Gets the default value for the number of messages that a page in the
  * results produced by the method <code>search</code> can holds.
  *
  * @return	the page size
  */
  public int getDefaultSearchPageSize() {
    return mdb.getDefaultPageSize();
  }

  /**
  * Sets the default value for the number of messages that a page in the
  * results produced by the method <code>search</code> can holds.
  *
  * @param pageSize	the page size
  * @see		#setSearchPageSize
  */
  public void setDefaultSearchPageSize(int pageSize) {
    mdb.setDefaultPageSize(pageSize);
  }

  /**
  * Sets the sort key by which the results produced by the method
  * <code>readForums</code> are sorted. The default value is specified by the
  * method <code>setDefaultForumSortKey</code>.
  *
  * @param sortKey	one of the FORUM_ORDER_* values
  * @see		#readForums
  * @see		#setDefaultForumSortKey
  */
  public void setForumSortKey(String sortKey) {
    fdb.setSortKey(sortKey);
  }

  /**
  * Sets the sort key by which the results produced by the method
  * <code>readThreads</code> are sorted. The default value is specified by the
  * method <code>setDefaultThreadSortKey</code>.
  *
  * @param sortKey	one of the THREAD_ORDER_* values
  * @see		#readThreads
  * @see		#setDefaultThreadSortKey
  */
  public void setThreadSortKey(String sortKey) {
    tdb.setSortKey(sortKey);
  }

  /**
  * Sets the number of threads that a page in the results produced by the
  * method <code>readThreads</code> can holds. A page size of 0 means that
  * results are not splitted into multiple pages. The default value is
  * specified by the method <code>setDefaultThreadPageSize</code>.
  *
  * @param pageSize	the page size
  * @see		#readThreads
  * @see		#setDefaultThreadPageSize
  */
  public void setThreadPageSize(int pageSize) {
    tdb.setPageSize(pageSize);
  }

  /**
  * Sets the sort key by which the results produced by the method
  * <code>readMessages</code> are sorted. The default value is specified by the
  * method <code>setDefaultMessageSortKey</code>.
  *
  * @param sortKey	one of the MESSAGE_ORDER_* values
  * @see		#readMessages
  * @see		#setDefaultMessageSortKey
  */
  public void setMessageSortKey(String sortKey) {
    mdb.setSortKey(sortKey);
  }

  /**
  * Sets the number of messages that a page in the results produced by the
  * method <code>search</code> can holds. A page size of 0 means that results
  * are not splitted into multiple pages. The default value is specified by the
  * method <code>setDefaultMessagePageSize</code>.
  *
  * @param pageSize	the page size
  * @see		#search
  * @see		#setDefaultSearchPageSize
  */
  public void setSearchPageSize(int pageSize) {
    mdb.setPageSize(pageSize);
  }

  /**
  * Gets the ID of the current forum.
  *
  * @return	the forum ID
  */
  public int getForumID() {
    return fid;
  }

  /**
  * Sets the current forum to the one with the given ID.
  *
  * @param id	the forum ID
  */
  public void setForumID(int id) {
    fid = id;
    forum = null;
    thread = null;
    message = null;
    neighbourThreadsRead = false;
    neighbourMessagesRead = false;
  }

  /**
  * Gets the ID of the current thread.
  *
  * @return	the thread ID
  */
  public int getThreadID() {
    return tid;
  }

  /**
  * Sets the current thread to the one with the given ID.
  *
  * @param id	the thread ID
  */
  public void setThreadID(int id) {
    tid = id;
    thread = null;
    neighbourThreadsRead = false;
  }

  /**
  * Gets the ID of the current message.
  *
  * @return	the message ID
  */
  public int getMessageID() {
    return mid;
  }

  /**
  * Sets the current message to the one with the given ID.
  *
  * @param id	the message ID
  */
  public void setMessageID(int id) {
    mid = id;
    message = null;
    neighbourMessagesRead = false;
    if (tid == 0) {
      thread = null;
      neighbourThreadsRead = false;
    }
  }

  /**
  * Gets the ID of the newly created message.
  *
  * @return	the message ID
  * @see	#post
  * @see	#reply
  */
  public int getNewMessageID() {
    return newMID;
  }

  /**
  * Sets the name of a forum.
  *
  * @param name	the name
  * @see	#createForum
  */
  public void setName(String name) {
    this.name = name;
  }

  /**
  * Sets the description of a forum.
  *
  * @param descr	the description
  * @see		#createForum
  */
  public void setDescription(String descr) {
    this.descr = descr;
  }

  /**
  * Sets the subject of a thread or a message.
  *
  * @param subject	the subject
  * @see		#createThread
  * @see		#post
  * @see		#reply
  */
  public void setSubject(String subject) {
    this.subject = subject.trim();
  }

  /**
  * Sets the body of a message.
  *
  * @param body	the message body
  * @see	#post
  * @see	#reply
  */
  public void setBody(String body) {
    this.body = body;
  }

  /**
  * Sets the name of the author of a message.
  *
  * @param author	the name
  * @see		#post
  * @see		#reply
  */
  public void setAuthor(String author) {
    this.author = author;
  }

  /**
  * Sets the e-mail address of the author of a message.
  *
  * @param email	the e-mail address
  * @see		#post
  * @see		#reply
  */
  public void setEmail(String email) {
    this.email = email;
  }

  /**
  * Sets the homepage location of the author of a message.
  *
  * @param homepage	the homepage location
  * @see		#post
  * @see		#reply
  */
  public void setHomepage(String homepage) {
    this.homepage = homepage;
  }

  /**
  * Sets the phrase to be searched for.
  *
  * @param phrase	the phrase
  * @see		#search
  */
  public void setPhrase(String phrase) {
    this.phrase = phrase;
  }

  /**
  * Tells which page of threads in the results is retrieved.
  *
  * @return	the page number
  * @see	#readThreads
  * @see	#setThreadPageSize
  */
  public int getThreadPage() {
    return tdb.getPage();
  }

  /**
  * Chooses a page of threads in the results to retrieve. By default, the first
  * page is retrieved.
  *
  * @param page	the page number
  * @see	#readThreads
  * @see	#setThreadPageSize
  */
  public void setThreadPage(int page) {
    tdb.setPage(page);
  }

  /**
  * Tells which page in the results of a search is retrieved.
  *
  * @return	the page number
  * @see	#search
  * @see	#setSearchPageSize
  */
  public int getSearchPage() {
    return mdb.getPage();
  }

  /**
  * Chooses a page in the results of a search to retrieve. By default, the
  * first page is retrieved.
  *
  * @param page	the page number
  * @see	#search
  * @see	#setSearchPageSize
  */
  public void setSearchPage(int page) {
    mdb.setPage(page);
  }

  /**
  * Gets the current forum.
  *
  * @return	the current forum
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  */
  public ForumData getForum() throws Exception {
    if (forum != null) return forum;

    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	return forum = fdb.getForum(con, fid);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Gets the current thread in the current forum. The current thread is
  * automatically determined from the current message if it is not set.
  *
  * @return	the current thread
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  * @see	#setMessageID
  */
  public ThreadData getThread() throws Exception {
    if (thread != null) return thread;

    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	int id = (tid != 0 || mid == 0) ? tid : deriveThreadID(con);
	return thread = tdb.getThread(con, fid, id);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Gets the next thread of the current one in the current forum. The current
  * thread is automatically determined from the current message if it is not
  * set.
  *
  * @return	the thread; <code>null</code> if no such thread exists.
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  * @see	#setMessageID
  */
  public ThreadData getNextThread() throws Exception {
    if (!neighbourThreadsRead) readNeighbouringThreads();
    return nextThread;
  }

  /**
  * Gets the previous thread of the current one in the current forum. The
  * current thread is automatically determined from the current message if it
  * is not set.
  *
  * @return	the thread; <code>null</code> if no such thread exists.
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  * @see	#setMessageID
  */
  public ThreadData getPreviousThread() throws Exception {
    if (!neighbourThreadsRead) readNeighbouringThreads();
    return prevThread;
  }

  /**
  * Gets the current message in the current forum.
  *
  * @return	the current message
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  */
  public MessageData getMessage() throws Exception {
    if (message != null) return message;

    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	return message = mdb.getMessage(con, fid, mid);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Gets the next message of the current one in the current forum.
  *
  * @return	the message; <code>null</code> if no such message exists.
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  */
  public MessageData getNextMessage() throws Exception {
    if (!neighbourMessagesRead) readNeighbouringMessages();
    return nextMessage;
  }

  /**
  * Gets the previous message of the current one in the current forum.
  *
  * @return	the message; <code>null</code> if no such message exists.
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  */
  public MessageData getPreviousMessage() throws Exception {
    if (!neighbourMessagesRead) readNeighbouringMessages();
    return prevMessage;
  }

  /**
  * Gets the number of pages in the whole set of results.
  *
  * @return	the number of pages
  * @see	#readThreads
  * @see	#search
  */
  public int getPageCount() {
    return pageCount;
  }

  /**
  * Reads all forums. The results are of the type <code>ForumData</code> and
  * can be retrieved through the interface <code>ResultIterator</code>.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @see	#setForumSortKey
  * @see	ForumData
  * @see	ResultIterator
  */
  public void readForums() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	results = fdb.getForums(con);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      results = null;
      throw e;
    }
  }

  /**
  * Reads a page of threads in the current forum. The results are of the type
  * <code>ThreadData</code> and can be retrieved through the interface
  * <code>ResultIterator</code>.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadSortKey
  * @see	#setThreadPageSize
  * @see	#setThreadPage
  * @see	ThreadData
  * @see	ResultIterator
  */
  public void readThreads() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	if (forum == null) forum = fdb.getForum(con, fid);
	results = tdb.getThreads(con, fid);
	pageCount = tdb.getPageSize() > 0 ? (forum.getThreadCount()
		+ tdb.getPageSize() - 1) / tdb.getPageSize()
		: forum.getThreadCount() > 0 ? 1 : 0;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      results = null;
      pageCount = 0;
      throw e;
    }
  }

  /**
  * Reads all messages in the current thread. The results are of the type
  * <code>MessageData</code> and can be retrieved through the interface
  * <code>ResultIterator</code>. The current thread is automatically determined
  * from the current message if it is not set.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  * @see	#setMessageID
  * @see	#setMessageSortKey
  * @see	MessageData
  * @see	ResultIterator
  */
  public void readMessages() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	int id;
	if (thread == null) {
	  id = (tid != 0 || mid == 0) ? tid : deriveThreadID(con);
	  thread = tdb.getThread(con, fid, id);	// redundant
	} else id = tid;
	results = mdb.getMessages(con, fid, id);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      results = null;
      throw e;
    }
  }

  
   public void readMessages(int tid, int fid) throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	int id;
	if (thread == null) {
	  id = (tid != 0 || mid == 0) ? tid : deriveThreadID(con);
	  thread = tdb.getThread(con, fid, id);	// redundant
	} else id = tid;
	results = mdb.getMessages(con, fid, id);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      results = null;
      throw e;
    }
  }

   
  /**
  * Reads all direct replies of the current message in the current forum. The
  * results are of the type <code>MessageData</code> and can be retrieved
  * through the interface <code>ResultIterator</code>.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  * @see	MessageData
  * @see	ResultIterator
  */
  public void readReplies() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	results = mdb.getReplies(con, fid, mid);
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      results = null;
      throw e;
    }
  }

  /**
  * Searches in the current forum for messages containing a phrase. The phrase
  * should be set by the method <code>setPhrase</code> prior to making this
  * call. The results are of the type <code>MessageData</code> and can be
  * retrieved through the interface <code>ResultIterator</code>.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setPhrase
  * @see	#setSearchPageSize
  * @see	#setSearchPage
  * @see	MessageData
  * @see	ResultIterator
  */
  public void search() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	results = mdb.search(con, fid, phrase);
	pageCount = mdb.getPageSize() > 0 ? (mdb.getResultCount()
		+ mdb.getPageSize() - 1) / mdb.getPageSize()
		: mdb.getResultCount() > 0 ? 1 : 0;
      } finally {
	////con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      results = null;
      pageCount = 0;
      throw e;
    }
  }

  /**
  * Creates a forum. Properties of the forum should be set by methods
  * <code>setName</code> and <code>setDescription</code> prior to making this
  * call.
  *
  * @return	the ID of the new forum
  * @exception java.sql.SQLException	if a database access error occurs
  * @see	#setName
  * @see	#setDescription
  */
  public int createForum() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setAutoCommit(false);
	int id = createForum(con);
	con.commit();
	return id;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Creates a forum using a given database connection. Properties of the
  * forum should be set by methods <code>setName</code> and
  * <code>setDescription</code> prior to making this call.
  *
  * @param con	a database connection
  * @return	the ID of the new forum
  * @exception java.sql.SQLException	if a database access error occurs
  * @see	#setName
  * @see	#setDescription
  */
  public int createForum(Connection con) throws SQLException {
    return fdb.insert(con, name, descr);
  }

  /**
  * Creates a thread in the current forum. The subject of the thread should be
  * set by the method <code>setSubject</code> prior to making this call.
  *
  * @return	the ID of the new thread
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setSubject
  */
  public int createThread() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setAutoCommit(false);
	int id = createThread(con);
	con.commit();
	forum = null;
	return id;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Creates a thread in the current forum using a given database connection.
  * The subject of the thread should be set by methods <code>setSubject</code>
  * prior to making this call.
  *
  * @param con	a database connection
  * @return	the ID of the new thread
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setSubject
  */
  public int createThread(Connection con)
	throws SQLException, IllegalDataException {
    int id = fdb.allocateThread(con, fid);
    tdb.insert(con, fid, id, subject, 0);
    return id;
  }

  /**
  * Posts a message to the current forum. Properties of the message should be
  * set by methods <code>setSubject</code>, <code>setBody</code>,
  * <code>setAuthor</code>, <code>setEmail</code> and <code>setHomepage</code>
  * prior to making this call. If the current thread is set, the new message is
  * posted to that thread; Otherwise, it is posted to a newly created thread.
  * The ID of the new message is returned by the method
  * <code>getNewMessageID</code>.
  *
  * @return	the ID of the thread to which the message is posted
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  * @see	#setSubject
  * @see	#setBody
  * @see	#setAuthor
  * @see	#setEmail
  * @see	#setHomepage
  * @see	#getNewMessageID
  */
  public int post() throws Exception {
    if (subject.equals("") && body.equals(""))
      throw new IllegalDataException("forum.emptymessage");

    try {
      Connection con = connect();

      try {
	con.setAutoCommit(false);
	int id;
	if (tid == 0) {
	  fdb.allocateThreadMessage(con, fid);
	  id = fdb.getThreadID();
	  newMID = fdb.getMessageID();
	  tdb.insert(con, fid, id, subject, 1);
	} else {
	  newMID = fdb.allocateMessage(con, fid);
	  tdb.addMessage(con, fid, id = tid);
	}
	mdb.insert(con, fid, newMID, id, 0, subject, body,
		author, email, homepage);
	con.commit();
	forum = null;
	thread = null;
	return id;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      newMID = 0;
      throw e;
    }
  }

  /**
  * Replies to the current message. Properties of the message should be set by
  * methods <code>setSubject</code>, <code>setBody</code>,
  * <code>setAuthor</code>, <code>setEmail</code> and <code>setHomepage</code>
  * prior to making this call.
  *
  * @return	the ID of the new message
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  * @see	#setSubject
  * @see	#setBody
  * @see	#setAuthor
  * @see	#setEmail
  * @see	#setHomepage
  */
  public int reply() throws Exception {
    if (subject.equals("") && body.equals(""))
      throw new IllegalDataException("forum.emptymessage");

    try {
      Connection con = connect();

      try {
	int tid = deriveThreadID(con);
	con.setAutoCommit(false);
	newMID = fdb.allocateMessage(con, fid);
	tdb.addMessage(con, fid, tid);
	mdb.insert(con, fid, newMID, tid, mid, subject, body,
		author, email, homepage);
	con.commit();
	forum = null;
	thread = null;
	return newMID;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      newMID = 0;
      throw e;
    }
  }

  /**
  * Deletes the current forum.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  */
  public void deleteForum() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setAutoCommit(false);
	deleteForum(con);
	con.commit();
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Deletes the current forum using a given database connection.
  *
  * @param con	a database connection
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  */
  public void deleteForum(Connection con)
	throws SQLException, IllegalDataException {
    fdb.delete(con, fid);
    tdb.delete(con, fid);
    mdb.delete(con, fid);
  }

  /**
  * Deletes the current thread from the current forum.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  */
  public void deleteThread() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setAutoCommit(false);
	deleteThread(con);
	con.commit();
	forum = null;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Deletes the current thread from the current forum using a given database
  * connection. The current thread is automatically determined from the current
  * message if it is not set.
  *
  * @param con	a database connection
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setThreadID
  * @see	#setMessageID
  */
  public void deleteThread(Connection con)
	throws SQLException, IllegalDataException {
    int id = (tid != 0 || mid == 0) ? tid : deriveThreadID(con);
    fdb.deleteThread(con, fid);
    tdb.delete(con, fid, id);
    fdb.deleteMessage(con, fid, mdb.delete(con, fid, id));
  }

  /**
  * Deletes the current message from the current forum.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  */
  public void deleteMessage() throws Exception {
    try {
      Connection con = connect();

      try {
	int tid = deriveThreadID(con);
	con.setAutoCommit(false);
	fdb.deleteMessage(con, fid, 1);
	mdb.delete(con, fid, mid, tid, message.getReplyToID());
	tdb.deleteMessage(con, fid, tid, 1);
	con.commit();
	forum = null;
	thread = null;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Deletes the current message and all replies from the current forum.
  *
  * @exception java.sql.SQLException	if a database access error occurs
  * @exception IllegalDataException	if the operation fails due to an
  *					incorrect data
  * @see	#setForumID
  * @see	#setMessageID
  */
  public void deleteMessageTree() throws Exception {
    try {
      Connection con = connect();

      try {
	int tid = deriveThreadID(con);
	con.setAutoCommit(false);
	fdb.deleteMessage(con, fid, 1);
	int c = mdb.delete(con, fid, mid, tid);
	tdb.deleteMessage(con, fid, tid, c);
	fdb.deleteMessage(con, fid, c - 1);
	con.commit();
	forum = null;
	thread = null;
      } catch (Exception e) {
	con.rollback();
	throw e;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      throw e;
    }
  }

  /**
  * Clears this object by removing the values of properties. Values set by
  * methods <code>setForumID</code>, <code>setThreadID</code>,
  * <code>setMessageID</code>, <code>setName</code>,
  * <code>setDescription</code>, <code>setSubject</code>, <code>setBody</code>,
  * <code>setAuthor</code>, <code>setEmail</code>, <code>setHomepage</code>,
  * <code>setPhrase</code>, <code>setThreadPage</code> and
  * <code>setSearchPage</code> are removed.
  */
  public void clear() {
    fid = tid = mid = newMID = pageCount = 0;
    name = descr = subject = body = author = email = homepage = phrase = "";
    forum = null;
    thread = null;
    message = null;
    results = null;
    neighbourThreadsRead = neighbourMessagesRead = false;
    tdb.setPage(1);
    mdb.setPage(1);
  }

  /**
  * Clears this object and restores properties to their default values set by
  * <code>setDefaultXXX</code> methods. The method <code>clear</code> is
  * called, and values set by methods <code>setForumSortKey</code>,
  * <code>setThreadSortKey</code>, <code>setThreadPageSize</code>,
  * <code>setMessageSortKey</code> and <code>setSearchPageSize</code> are
  * restored.
  *
  * @see	#clear
  */
  public void reset() {
    clear();
    fdb.reset();
    tdb.reset();
    mdb.reset();
  }

  /**
  * Makes a database connection.
  */
  private Connection connect() throws SQLException {
    try {
      DADDBConnection connection = new DADDBConnection();
      return (connection.ConnectDB2());
        
     // return//((DBConnection)Customizer.instantiate(dbConBeanName)).connect();
    }  catch (Exception e) {
      throw new SQLException(e.getMessage());
    }
  }
  
  

  /**
  * Determines the thread ID from a message.
  */
  private int deriveThreadID(Connection con)
	throws SQLException, IllegalDataException {
    if (message == null) message = mdb.getMessage(con, fid, mid);
    return message.getThreadID();
  }

  /**
  * Reads neighbouring threads of the current one.
  */
  private void readNeighbouringThreads() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	int id = (tid != 0 || mid == 0) ? tid : deriveThreadID(con);
	nextThread = tdb.getNextThread(con, fid, id);
	prevThread = tdb.getPreviousThread(con, fid, id);
	neighbourThreadsRead = true;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      neighbourThreadsRead = false;
      throw e;
    }
  }

  /**
  * Reads neighbouring messages of the current one.
  */
  private void readNeighbouringMessages() throws Exception {
    try {
      Connection con = connect();

      try {
	con.setReadOnly(true);
	nextMessage = mdb.getNextMessage(con, fid, mid);
	prevMessage = mdb.getPreviousMessage(con, fid, mid);
	neighbourMessagesRead = true;
      } finally {
	//con.close();
      }
    } catch (Exception e) {
      Log.error(e);
      neighbourMessagesRead = false;
      throw e;
    }
  }


  // Methods inherited from interface Customizee

  boolean customized = false;

  public boolean isCustomized() {
    return customized;
  }

  public void setCustomized(boolean customized) {
    this.customized = customized;
  }


  // Methods inherited from interface ResultIterator

  public Vector getResults() {
    return results != null ? new Vector(results) : null;
  }

  public int getResultCount() {
    return results != null ? results.size() : 0;
  }

  public boolean hasNextResult() {
    return results != null ? results.hasNext() : false;
  }

  public Object nextResult() {
    return results != null ? results.next() : null;
  }

  public void rewindResults() {
    if (results != null) results.rewind();
  }
}
