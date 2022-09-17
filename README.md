# solr_scaffold_template -- generate a simple solr analysis filter

This is a simple generator to get a mostly-novice up-and-running with
a custom analysis filter for their Solr project. See the base project
[solr_scaffold](https://github.com/billdueber/solr_scaffold) for more
information about this kind of filter, as well as how to easily subclass
`solr.StrField` with your own analysis (optionally changing the stored
version of the field as well).


**Note**: The "right" way to do this is almost certainly by getting
`solr_scaffold` into a maven repository and/or creating a maven
archetypes, but that seems like a lot of work before we know if anyone cares.


## Step 1: Generate

Supposed you want to make a filter to lowercase everything (ignoring
that there are already better options).

* **What should we call it?** Must be a java classname and hence start 
  with an uppercase letter. So...`Lowercasify`
* **What package should it be in?** Filters in solr in are something.
  something.solr.analysis, so I'll use `com.billdueber.solr.analysis`

```shell

git clone git@github.com:billdueber/solr_scaffold_template lowercasify
cd lowercasify
ruby generate.rb com.billdueber.solr.analysis Lowercasify

```

## Step 2: Edit the filter

Two files were generated at the end of your package hierarchy under
`src/main/java`: `LowercasifyFilter.java` and `LowercasifyFilterFactory.java`.

`LowercasifyFilterFacoty.java` is probably fine just as it is, and you can 
leave it alone.

`LowercasifyFilter.java` has a method in it, `munge`, which is where you 
put your string transformation logic. It can all live in there, or you can 
create other java files, pull other stuff in via the POM, etc.

```java
package com.billdueber.solr.analysis;


import com.billdueber.solr_scaffold.analysis.SimpleFilter;
import org.apache.lucene.analysis.TokenStream;

/**
 *  For most cases, all you need to do is edit the `munge` method
 *  and leave the constructor alone.
**/

public class LowercasifyFilter extends SimpleFilter {

  public LowercasifyFilter(TokenStream aStream, Boolean echoInvalidInput) {
    super(aStream, echoInvalidInput);
  }

  @Override
  public String munge(String str) {
//    return str;
    return str.toLowerCase(); // I M SO SMRT!
  }

}


```

## Step 3: Build it

```shell
mvn package
```

That was easy.

## Step 4: Get the .jar files where your solr will find them.

There are two .jar files you'll need to grab
* `target/yourfilter-yourversion.jar`
* `repo/com/billdueber/solr_scaffold/1.0/solr_scaffold-1.0.jar`

These need to be put where your solr can find them. This is often 
controlled via the `solrconfig.xml` file; I put this line in mine

```xml
 <lib dir="${solr.core.config}/lib" regex=".*\.jar"/>
```

...and then I can have a `lib/` directory right next to `conf/` in my solr 
configuration. 

## Step 5: Use it in your schema.xml

```xml

<fieldType name="lowercasify" class="solr.TextField">
  <analyzer>
    <tokenizer class="solr.KeywordTokenizerFactory"/>
    <filter class="com.billdueber.solr.analysis.LowercaseifyFilterFactory"/>
  </analyzer>
</fieldType>


```