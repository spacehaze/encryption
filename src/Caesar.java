package src;

public class Caesar implements Cryptography{

    @Override
    public StringBuilder encrypt(String message, int key) {
        StringBuilder result = new StringBuilder();

        for (char c : message.toCharArray()) {
            if (c != ' ') {
                int originalAlphabetPosition = c - 'a';
                int newAlphabetPosition = (originalAlphabetPosition + key);
                char newCharacter = (char) ('a' + newAlphabetPosition);
                result.append(newCharacter);
            } else {
                result.append(c);
            }
        }
        return result;
    }

    @Override
    public StringBuilder decrypt(String message, int key) {
        StringBuilder result = new StringBuilder();

        for (char c : message.toCharArray()) {
            if (c != ' ') {
                int originalAlphabetPosition = c - 'a';
                int newAlphabetPosition = (originalAlphabetPosition - key);
                char newCharacter = (char) ('a' + newAlphabetPosition);
                result.append(newCharacter);
            } else {
                result.append(c);
            }
        }
        return result;
    }
}
