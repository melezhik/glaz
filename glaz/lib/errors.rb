class Task
    class Error < StandardError
        attr_accessor :message
        def initialize message
            @message = message
        end
    end
end

class Task
    class SkipError < Task::Error
    end
end

