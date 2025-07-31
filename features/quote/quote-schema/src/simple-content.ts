import {
  ContentDescriptor,
  ContentSchemaBuilder,
} from '@vyuh/sanity-schema-core';
import { defineField, defineType, SchemaTypeDefinition } from 'sanity';

export class SimpleContentDescriptor extends ContentDescriptor {
  static schemaName = 'quoteSchema.simple.content';

  constructor() {
    super(SimpleContentDescriptor.schemaName, {});
  }
}

export class SimpleContentSchemaBuilder extends ContentSchemaBuilder {
  schema: SchemaTypeDefinition = defineType({
    name: SimpleContentDescriptor.schemaName,
    title: 'Simple',
    type: 'object',
    fields: [
      defineField({
        name: 'text',
        title: 'Quote Text',
        type: 'text',
        validation: (Rule) => Rule.required().min(10),
      }),
      defineField({
        name: 'author',
        title: 'Author',
        type: 'string',
      }),
      defineField({
        name: 'date',
        title: 'Posted Date',
        type: 'datetime',
        validation: (Rule) => Rule.required(),
      }),
      defineField({
        name: 'isFeatured',
        title: 'Featured (Quote of the Day)',
        type: 'boolean',
        initialValue: false,
      }),
    ],
    preview: {
      select: {
        title: 'text',
        subtitle: 'author',
      },
      prepare(selection: any) {
        return {
          title: selection.title,
          subtitle: selection.subtitle ? `by ${selection.subtitle}` : undefined,
        };
      },
    },

  });

  constructor() {
    super(SimpleContentDescriptor.schemaName);
  }

  build(descriptors: ContentDescriptor[]) {
    return this.schema;
  }
}
