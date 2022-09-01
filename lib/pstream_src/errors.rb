module PstreamSrc
    class InvalidVideoIDError < StandardError
        def message
            "pstream.net did not returned 200, video id may be invalid or request may be missing some http headers."
        end
    end

    class UnthoughtError < StandardError
        def message
            "An error occured because of an unthought situation, pstream may have changed their source code or your video may be an exception."
        end
    end
end