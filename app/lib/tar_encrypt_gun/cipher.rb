module TarEncryptGun
  class Cipher
    # == Constants ============================================================
    Algorithm = RbNaCl::AEAD::ChaCha20Poly1305IETF

    class CipherError < StandardError; end

    # == Attributes ===========================================================

    # == Extensions ===========================================================

    # == Boolean Class Methods ================================================

    # == Class Methods ========================================================
    def self.random_bytes(n = 32)
      RbNaCl::Random.random_bytes n
    end

    # == Boolean Methods ======================================================

    # == Instance Methods =====================================================
    def auth_data=(auth_data)
      @auth_data = ""
    end

    def decrypt
      @method = :decrypt
    end

    def encrypt
      @method = :encrypt
    end

    def random_key
      self.class.random_bytes Algorithm.key_bytes
    end

    def random_iv
      self.class.random_bytes @cipher&.nonce_bytes
    end

    def key=(key)
      @key    = key
      @cipher = Algorithm.new(key)
      @key
    end

    def iv=(iv)
      @iv = iv
    end

    def run(message)
      set_direction @method
      @cipher.__send__ @method, @iv, message, (@auth_data || "")
    end

    def set_direction(direction)
      case direction
      when :encrypt
        self.encrypt
      when :decrypt
        self.decrypt
      else
        raise CipherError.new("invalid direction")
      end
    end
    alias :direction= :set_direction
  end
end
