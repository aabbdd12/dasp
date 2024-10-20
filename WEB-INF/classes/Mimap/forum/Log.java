

package Mimap.forum;

public class Log {

   protected Log() {}

   public static void error(String s) {
    System.err.println(s);
  }

   public static void error(Throwable t) {
    t.printStackTrace();
  }
}
