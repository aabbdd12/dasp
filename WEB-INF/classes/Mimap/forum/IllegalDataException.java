

package Mimap.forum;

import java.text.*;
import java.util.*;

public class IllegalDataException extends Exception {
  private static String resource = "Mimap.forum.ExceptionMessages";
  private static Object[] noArg = {};
  private static ResourceBundle bundle = null;

public IllegalDataException() {}
public IllegalDataException(String s) {
    super(formatMessage(s, noArg));
  }

public IllegalDataException(String s, Object[] args) {
    super(formatMessage(s, args));
  }
  public IllegalDataException(String s, Object x) {
    super(formatMessage(s, prepareArguments(x)));
  }

  public IllegalDataException(String s, Object x1, Object x2) {
    super(formatMessage(s, prepareArguments(x1, x2)));
  }

   public IllegalDataException(String s, int x) {
    super(formatMessage(s, prepareArguments(String.valueOf(x))));
  }

   public IllegalDataException(String s, int x1, int x2) {
    super(formatMessage(s, prepareArguments(
	String.valueOf(x1), String.valueOf(x2))));
  }

  private static Object[] prepareArguments(Object x) {
    Object[] args = {x};
    return args;
  }

  private static Object[] prepareArguments(Object x1, Object x2) {
    Object[] args = {x1, x2};
    return args;
  }

  private static String formatMessage(String key, Object[] args) {
    try {
      if (bundle == null) bundle = ResourceBundle.getBundle(resource);
      return MessageFormat.format(bundle.getString(key), args);
    } catch (Exception e) {
      return "";
    }
  }
}
