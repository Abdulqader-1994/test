import { D1QB } from "workers-qb";
import { curriculumRef, subscribedRef } from "../graphql/refs";
import { Curriculum, queryBuilderType, Subscribed } from "../graphql/types";
import { checkAuth } from "../utils/check_auth";

export default class Study {
  static getSubscribedMaterials = (t: queryBuilderType) => t.field({
    type: [subscribedRef],
    args: {
      jwtToken: t.arg.string({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      const { id } = await checkAuth(args.jwtToken, ctx.env)

      const subscribed: Subscribed[] = []

      const database = new D1QB(ctx.env.TASK_DB)
      const res = await database.fetchAll({
        tableName: 'subscribed',
        where: { conditions: 'userId = ?1', params: [id] },
        join: { type: 'INNER', table: 'curriculum', on: 'subscribed.curriculumId = curriculum.id' },
      }).execute()

      if (res.results == undefined || res.results.length == 0) return subscribed

      for (const el of res.results) {
        subscribed.push({
          id: el.id as number,
          createdAt: el.createdAt as number,
          name: el.name as string,
          countryId: el.countryId as number,
          levelType: el.levelType as number,
          level: el.level as string,
          semester: el.semester as number,
          finished: el.finished as string,
          purchased: el.purchased as number,
        })
      }

      return subscribed
    }
  })

  static getMaterials = (t: queryBuilderType) => t.field({
    type: [curriculumRef],
    args: {
      jwtToken: t.arg.string({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      await checkAuth(args.jwtToken, ctx.env)

      const result: Curriculum[] = [];

      const database = new D1QB(ctx.env.TASK_DB)
      const res = await database.fetchAll({ tableName: 'curriculum' }).execute()

      if (res.results == undefined || res.results.length == 0) return result;

      for (let i = 0; i < res.results.length; i++) {
        result.push({
          id: res.results[i].id as number,
          name: res.results[i].name as string,
          countryId: res.results[i].countryId as number,
          levelType: res.results[i].levelType as number,
          semester: res.results[i].semester as number,
          level: res.results[i].level as string,
          completedPercent: res.results[i].completedPercent as number,
          openToWork: res.results[i].openToWork as number,
        })
      }

      return result;
    }
  })
}