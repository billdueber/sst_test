#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'


def usage
  puts <<~USAGEDOC
  USAGE 
    ruby generate.rb com.example.mypackagename MyFiltername
  
  Note that the package is all lowercase, and the filter name
  must start with an uppercase letter

  Example:
    ruby generate.rb com.billdueber.solr.analysis Lowercasify

  USAGEDOC
  exit 1
end

usage unless ARGV.size == 2

package = ARGV.shift
filtername = ARGV.shift
artifact = filtername.downcase

if package =~ /[A-Z]/
  puts "Package shouldn't use uppercase letters (generally)"
  usage
end

unless filtername =~ /\A[A-Z]/
  puts "Class name for filter should start with an uppercase letter"
  usage
end

puts
puts "Package:       #{package}"
puts "Filter class:  #{filtername}"
puts
print "OK? (y/N) "
response = gets.chomp
exit(1) unless response =~ /\A\s*[Yy]\s*\Z/


factory = %Q(
package #{package};

import com.billdueber.solr_scaffold.analysis.SimpleFilterFactory;
import org.apache.lucene.analysis.TokenStream;

import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;
import java.lang.invoke.MethodHandles;
/**
 *  Unless you're doing something weird, you shouldn't have to
 *  edit this file at all.
 *
 *  Add it to a solr analysis chain with something like
 *    <filter class="#{package}.#{filtername}" echoInvalidInput="false"/>
**/

public class #{filtername}FilterFactory extends SimpleFilterFactory {

  public static Logger log = LoggerFactory
      .getLogger(MethodHandles.lookup().lookupClass());

  public #{filtername}FilterFactory(Map<String, String> args) {
    super(args);
  }

  public #{filtername}Filter create(TokenStream input) {
    return new #{filtername}Filter(input, getEchoInvalidInput());
  }
}

)

filter =  %Q(
package #{package};


import com.billdueber.solr_scaffold.analysis.SimpleFilter;
import org.apache.lucene.analysis.TokenStream;
import java.util.regex.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.IOException;
import java.lang.invoke.MethodHandles;
/**
 *  For most cases, all you need to do is edit the `munge` method
 *  and leave the constructor alone.
**/

public class #{filtername}Filter extends SimpleFilter {

  public static Logger log = LoggerFactory
      .getLogger(MethodHandles.lookup().lookupClass());

  public #{filtername}Filter(TokenStream aStream, Boolean echoInvalidInput) {
    super(aStream, echoInvalidInput);
  }

  @Override
  public String munge(String str) {
    return str;
  }

}
)

target_dir = (%w[src main java].concat(package.split('.'))).join("/")
p = Pathname.new(__dir__) + target_dir
FileUtils.mkpath(p.to_s)

File.open(p + "#{filtername}Filter.java", 'w:utf-8') { |out| out.puts filter }
File.open(p + "#{filtername}FilterFactory.java", 'w:utf-8') { |out| out.puts factory }

pom = File.open('pom.xml').read

pom.gsub!('<groupId>org.example</groupId>', "<groupId>#{package}</groupId>")
pom.gsub!('<artifactId>solr_scaffold_template</artifactId>', "<artifactId>#{artifact}</artifactId>")

File.open('pom.xml', 'w:utf-8') {|out| out.puts pom}