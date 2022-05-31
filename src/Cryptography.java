package src;

public interface Cryptography {

    StringBuilder encrypt(String message, int key);

    StringBuilder decrypt(String message, int key);
}
