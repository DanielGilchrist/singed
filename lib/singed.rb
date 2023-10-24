# frozen_string_literal: true

require 'json'
require 'stackprof'
require 'colorize'

module Singed
  extend self

  def start(label = nil, open: true, ignore_gc: false, interval: 1000, io: $stdout)
    @flamegraph_options = {
      open: open,
      io: io
    }

    @flamegraph = Singed::Flamegraph.new(label: label, ignore_gc: ignore_gc, interval: interval)
    @flamegraph.start
  end

  def stop
    @flamegraph.stop
    @flamegraph.save

    io = @flamegraph_options.fetch(:io)

    if @flamegraph_options.fetch(:open)
      # use npx, so we don't have to add it as a dependency
      io.puts "🔥📈 #{'Captured flamegraph, opening with'.colorize(:bold).colorize(:red)}: #{@flamegraph.open_command}"
      @flamegraph.open
    else
      io.puts "🔥📈 #{'Captured flamegraph to file'.colorize(:bold).colorize(:red)}: #{@flamegraph.filename}"
    end
  end

  # Where should flamegraphs be saved?
  def output_directory=(directory)
    @output_directory = Pathname.new(directory)
  end

  def self.output_directory
    @output_directory
  end

  def enabled=(enabled)
    @enabled = enabled
  end

  def enabled?
    return @enabled if defined?(@enabled)

    @enabled = true
  end

  def backtrace_cleaner=(backtrace_cleaner)
    @backtrace_cleaner = backtrace_cleaner
  end

  def backtrace_cleaner
    @backtrace_cleaner
  end

  def silence_line?(line)
    return backtrace_cleaner.silence_line?(line) if backtrace_cleaner

    false
  end

  def filter_line(line)
    return backtrace_cleaner.filter_line(line) if backtrace_cleaner

    line
  end

  autoload :Flamegraph, 'singed/flamegraph'
  autoload :Report, 'singed/report'
  autoload :RackMiddleware, 'singed/rack_middleware'
end

require 'singed/kernel_ext'
require 'singed/railtie' if defined?(Rails::Railtie)
require 'singed/rspec' if defined?(RSpec) && RSpec.respond_to?(:configure)
