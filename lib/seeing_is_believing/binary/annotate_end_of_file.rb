require 'seeing_is_believing/binary' # defines the markers
require 'seeing_is_believing/binary/comment_formatter'

class SeeingIsBelieving
  module Binary
    module AnnotateEndOfFile
      extend self

      # TODO: Switch options to markers
      def add_stdout_stderr_and_exceptions_to(new_body, results, options)
        output = stdout_ouptut_for(results, options)    <<
                 stderr_ouptut_for(results, options)    <<
                 exception_output_for(results, options)

        # this technically could find an __END__ in a string or whatever
        # going to just ignore that, though
        if new_body[/^__END__$/]
          new_body.sub! "\n__END__", "\n#{output}__END__"
        else
          new_body << "\n" unless new_body.end_with? "\n"
          new_body << output
        end
      end

      def stdout_ouptut_for(results, options)
        return '' unless results.has_stdout?
        output = "\n"
        results.stdout.each_line do |line|
          output << CommentFormatter.call(0, options[:markers][:stdout], line.chomp, options) << "\n"
        end
        output
      end

      def stderr_ouptut_for(results, options)
        return '' unless results.has_stderr?
        output = "\n"
        results.stderr.each_line do |line|
          output << CommentFormatter.call(0, options[:markers][:stderr], line.chomp, options) << "\n"
        end
        output
      end

      def exception_output_for(results, options)
        return '' unless results.has_exception?
        exception_marker = options[:markers][:exception]
        exception = results.exception
        output = "\n"
        output << CommentFormatter.new(0, exception_marker, exception.class_name, options).call << "\n"
        exception.message.each_line do |line|
          output << CommentFormatter.new(0, exception_marker, line.chomp, options).call << "\n"
        end
        output << exception_marker.sub(/\s+$/, '') << "\n"
        exception.backtrace.each do |line|
          output << CommentFormatter.new(0, exception_marker, line.chomp, options).call << "\n"
        end
        output
      end
    end
  end
end
