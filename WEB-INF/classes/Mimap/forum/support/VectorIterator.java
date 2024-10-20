

package Mimap.forum.support;

import java.util.*;

public class VectorIterator extends Vector implements Iterator {
  Iterator itr = null;

  public VectorIterator() {}

  public VectorIterator(Collection c) {
    super(c);
  }

  public Object clone() {
    return new VectorIterator(this);
  }

  public boolean hasNext() {
    if (itr == null) itr = iterator();
    return itr.hasNext();
  }

  public Object next() {
    if (itr == null) itr = iterator();
    return itr.next();
  }

  public void remove() {
    if (itr == null) throw new IllegalStateException();
    itr.remove();
  }

  public void rewind() {
    itr = null;
  }
}
