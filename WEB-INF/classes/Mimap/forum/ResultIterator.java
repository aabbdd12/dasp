

package Mimap.forum;

public interface ResultIterator {

   public boolean hasNextResult();

   public Object nextResult();

   public void rewindResults();

   public java.util.Vector getResults();

   public int getResultCount();
}
