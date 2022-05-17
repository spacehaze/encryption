package src;

public class Main {

    public static StringBuilder encrypt(String message, int key) {
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

    public static StringBuilder decrypt(String message, int key) {
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


    public static void main(String[] args) {
        System.out.println(encrypt("attack at dawn", 1));
        System.out.println(decrypt("buubdl bu ebxo", 1));

    }
}
