

package Mimap.forum;

import java.beans.*;
import java.lang.reflect.*;
import java.util.*;

public class Customizer {

  private static final String resource = "Mimap.forum.Customization";

  private static ResourceBundle bundle = null;

  protected Customizer() {}

  public static Object instantiate(String name) throws Exception {
    return instantiate(Thread.currentThread().getContextClassLoader(), name);
  }

   public static Object instantiate(ClassLoader cls, String name)
	throws Exception {
    String beanName;

    try {
      loadBundle();
      beanName = bundle.getString(name + ".CLASS");
    } catch (MissingResourceException e) {
      beanName = name;
    }

    Object bean = Beans.instantiate(cls, beanName);
    if (_customize(bean, name) && bean instanceof Customizee)
      ((Customizee)bean).setCustomized(true);
    return bean;
  }

   public static void customize(Customizee bean, String name) throws Exception {
    if (bean.isCustomized()) return;

    loadBundle();
    _customize(bean, name);
    bean.setCustomized(true);
  }

  public static void customize(Object bean, String name) throws Exception {
    loadBundle();
    _customize(bean, name);
  }

  private static void loadBundle() {
    if (bundle == null) bundle = ResourceBundle.getBundle(resource);
  }

  private static boolean _customize(Object bean, String name)
	throws IntrospectionException, IllegalAccessException,
	InvocationTargetException {
    BeanInfo info = Introspector.getBeanInfo(bean.getClass());
    PropertyDescriptor[] prop = info.getPropertyDescriptors();
    name += ".";
    Object[] arg = new Object[1];
    boolean changed = false;

    for (int i = 0; i < prop.length; i++)
      try {
	String val = bundle.getString(name + prop[i].getName());
	Method writer = prop[i].getWriteMethod();
	Class[] param = writer.getParameterTypes();

	if (param[0].getName().equals("java.lang.String")) arg[0] = val;
	else if (param[0] == Boolean.TYPE) arg[0] = new Boolean(val);
	else if (param[0] == Byte.TYPE) arg[0] = new Byte(val);
	else if (param[0] == Character.TYPE)
	  arg[0] = new Character(val.charAt(0));
	else if (param[0] == Double.TYPE) arg[0] = new Double(val);
	else if (param[0] == Float.TYPE) arg[0] = new Float(val);
	else if (param[0] == Integer.TYPE) arg[0] = new Integer(val);
	else if (param[0] == Long.TYPE) arg[0] = new Long(val);
	else if (param[0] == Short.TYPE) arg[0] = new Short(val);
	else continue;

	writer.invoke(bean, arg);
	changed = true;
      } catch (MissingResourceException e) {}

    return changed;
  }
}
