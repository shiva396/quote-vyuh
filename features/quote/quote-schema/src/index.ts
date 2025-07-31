import { FeatureDescriptor } from '@vyuh/sanity-schema-core';
import { RouteDescriptor } from '@vyuh/sanity-schema-system';
import { SimpleContentDescriptor, SimpleContentSchemaBuilder } from './simple-content';

export const quoteSchema = new FeatureDescriptor({
  name: 'quoteSchema',
  title: 'Quote Schema',
  description: 'Schema for the Quote Schema feature',
  contents: [
    new RouteDescriptor({
      regionItems: [{ type: SimpleContentDescriptor.schemaName }],
    }),
  ],
  contentSchemaBuilders: [new SimpleContentSchemaBuilder()],
});
